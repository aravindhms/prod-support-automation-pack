#!/bin/bash
#
# System Vitals Dashboard
# A dependency-free terminal dashboard for Linux/Unix
#

# --- Setup & Cleanup ---

# Exit on error? No, we want to keep running even if one command fails momentarily
# set -e 

# Hide Cursor
tput civis

# Cleanup function to restore cursor and clear screen on exit
cleanup() {
    tput cnorm
    tput sgr0
    clear
    exit 0
}
trap cleanup SIGINT SIGTERM

# --- Colors & Styles ---
BOLD=$(tput bold)
RESET=$(tput sgr0)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
ORANGE=$(tput setaf 208) # Orange (Bright Yellow fallback)
if [ -z "$ORANGE" ]; then ORANGE=$(tput setaf 3); fi
BG_GREY=$(tput setab 0) # Usually black/dark grey

# --- Helper Functions ---

# Draw a bar chart
# Usage: draw_bar <percentage> <width> <color_code>
draw_bar() {
    local percent=$1
    local width=$2
    local color=$3
    
    local filled_len=$(( (percent * width) / 100 ))
    local empty_len=$(( width - filled_len ))
    
    # Cap filled_len at width
    if [ "$filled_len" -gt "$width" ]; then filled_len=$width; fi
    if [ "$filled_len" -lt 0 ]; then filled_len=0; fi

    local color=$GREEN
    if [ "$percent" -ge 50 ]; then color=$YELLOW; fi
    if [ "$percent" -ge 75 ]; then color=$ORANGE; fi
    if [ "$percent" -ge 90 ]; then color=$RED; fi

    printf "%s" "$color"
    for ((i=0; i<filled_len; i++)); do printf "█"; done
    printf "%s" "$RESET${BG_GREY}"
    for ((i=0; i<empty_len; i++)); do printf "░"; done
    printf "%s" "$RESET"
}

move_cursor() {
    tput cup $1 $2
}

# --- Data Collection ---

get_cpu_usage() {
    # Read /proc/stat
    # Line 1: cpu  user nice system idle iowait irq softirq steal guest guest_nice
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    
    # Calculate totals
    local total_idle=$((idle + iowait))
    local total_non_idle=$((user + nice + system + irq + softirq + steal))
    local total=$((total_idle + total_non_idle))
    
    # Calculate diff from previous (using global vars)
    local diff_idle=$((total_idle - PREV_IDLE))
    local diff_total=$((total - PREV_TOTAL))
    
    # Avoid division by zero
    if [ "$diff_total" -eq 0 ]; then
        echo "0"
    else
        local usage=$(( (1000 * (diff_total - diff_idle) / diff_total + 5) / 10 ))
        echo "$usage"
    fi
    
    # Update previous values for next run
    PREV_IDLE=$total_idle
    PREV_TOTAL=$total
}

get_mem_usage() {
    # returns: percent used_human total_human
    # Using free command which is fairly standard
    # Output format varies, but usually:
    #              total        used        free      shared  buff/cache   available
    # Mem:       16303232     6486844     2742136      622036     7074252     8882760
    
    local free_out=$(free -m | grep "Mem:")
    local total=$(echo "$free_out" | awk '{print $2}')
    local used=$(echo "$free_out" | awk '{print $3}')
    
    if [ "$total" -eq 0 ]; then echo "0 0M 0M"; return; fi
    
    local percent=$(( (used * 100) / total ))
    echo "$percent ${used}M ${total}M"
}

get_load_avg() {
    cat /proc/loadavg | awk '{print $1" "$2" "$3}'
}

get_disk_io() {
    # Returns read_kb_s write_kb_s
    # /proc/diskstats columns for sector read (6) and sector write (10)
    # usually 1 sector = 512 bytes
    local sectors=$(awk '{r+=$6; w+=$10} END {print r, w}' /proc/diskstats)
    echo "$sectors"
}

# --- State Initialization ---
PREV_TOTAL=0
PREV_IDLE=0
PREV_RX=0
PREV_TX=0
PREV_TIME=$(date +%s)
PREV_DISK_IO=$(get_disk_io)

# Run once to initialize "prev" values
read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
PREV_IDLE=$((idle + iowait))
PREV_TOTAL=$((user + nice + system + idle + iowait + irq + softirq + steal))

# Initialize Network
read -r _ _ PREV_RX _ _ _ _ _ _ PREV_TX _ < <(grep ":" /proc/net/dev | awk '{rx+=$2; tx+=$10} END {print "Total", "0", rx, "0", "0", "0", "0", "0", "0", tx, "0"}')

# Helper to get IP
GET_IP() {
    # Try hostname -I (common on Linux)
    local ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    if [ -z "$ip" ]; then
        # Fallback to ip addr
        ip=$(ip -4 addr show | grep -v "127.0.0.1" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
    fi
    echo "${ip:-Unknown}"
}
MY_IP=$(GET_IP)

# Services to monitor (customize this list)
SERVICES=("sshd" "systemd-journald" "systemd-resolved" "systemd-logind" "docker" "cron")

# --- UI Layout Helpers ---
get_layout() {
    local cols=$1
    if [ "$cols" -lt 100 ]; then
        echo "single"
    else
        echo "double"
    fi
}

# --- Main Loop ---
while true; do
    # 1. Update terminal size
    ROWS=$(tput lines)
    COLS=$(tput cols)
    
    # Calculate column split (roughly half)
    HALF_COLS=$((COLS / 2))
    
    # 2. Collect Data
    TIMESTAMP=$(date "+%H:%M:%S")
    HOSTNAME=$(hostname)
    OS=$(uname -sr)
    UPTIME=$(uptime -p | sed 's/up //')
    LOAD=$(get_load_avg)
    SYS_STATE=$(systemctl is-system-running 2>/dev/null || echo "unknown")
    
    CPU_USAGE=$(get_cpu_usage)
    
    MEM_DATA=$(get_mem_usage)
    read -r MEM_PCT MEM_USED MEM_TOTAL <<< "$MEM_DATA"
    
    # Network Calc
    CURR_TIME=$(date +%s)
    TIME_DIFF=$((CURR_TIME - PREV_TIME))
    if [ "$TIME_DIFF" -eq 0 ]; then TIME_DIFF=1; fi # avoid div 0
    
    # Sum up all interfaces for total traffic
    read -r _ _ CURR_RX _ _ _ _ _ _ CURR_TX _ < <(grep ":" /proc/net/dev | awk '{rx+=$2; tx+=$10} END {print "Total", "0", rx, "0", "0", "0", "0", "0", "0", tx, "0"}')
    
    RX_DIFF=$((CURR_RX - PREV_RX))
    TX_DIFF=$((CURR_TX - PREV_TX))
    
    RX_RATE=$((RX_DIFF / TIME_DIFF))
    TX_RATE=$((TX_DIFF / TIME_DIFF))
    
    # Convert to KB/s or MB/s
    human_readable_speed() {
        local bytes=$1
        if [ "$bytes" -gt 1048576 ]; then
            echo "$((bytes / 1048576)) MB/s"
        else
            echo "$((bytes / 1024)) KB/s"
        fi
    }
    
    RX_SPEED=$(human_readable_speed $RX_RATE)
    TX_SPEED=$(human_readable_speed $TX_RATE)
    
    # Disk IO Calc
    read -r CURR_R CURR_W <<< $(get_disk_io)
    read -r PREV_R PREV_W <<< "$PREV_DISK_IO"
    R_DIFF=$(( (CURR_R - PREV_R) * 512 / TIME_DIFF ))
    W_DIFF=$(( (CURR_W - PREV_W) * 512 / TIME_DIFF ))
    R_SPEED=$(human_readable_speed $R_DIFF)
    W_SPEED=$(human_readable_speed $W_DIFF)
    PREV_DISK_IO="$CURR_R $CURR_W"

    PREV_RX=$CURR_RX
    PREV_TX=$CURR_TX
    PREV_TIME=$CURR_TIME
    
    LAYOUT=$(get_layout $COLS)

    # 3. Draw UI
    clear
    
    # Header
    move_cursor 1 2
    echo "${BOLD}${CYAN} SERVER PERFORMANCE MONITOR ${RESET}"
    move_cursor 1 $((COLS - 20))
    echo "${WHITE}$TIMESTAMP${RESET}"
    
    move_cursor 3 2
    echo "Host: ${BOLD}$HOSTNAME${RESET} ($MY_IP)"
    move_cursor 3 $((HALF_COLS + 2))
    echo "OS: $OS"
    move_cursor 4 2
    echo "Uptime: $UPTIME"
    move_cursor 4 $((HALF_COLS + 2))
    echo "Load Avg: $LOAD | State: ${CYAN}$SYS_STATE${RESET}"
    
    # Horizontal Line
    move_cursor 5 0
    line_char="─"
    for ((i=0; i<COLS; i++)); do printf "%s" "$line_char"; done

    # Calculate Disk Usage once for both layouts
    read -r total_kb used_kb <<< $(df -k | grep -vE '^Filesystem|tmpfs|cdrom|loop|udev|overlay' | awk '{t+=$2; u+=$3} END {print t, u}')
    disk_pct=$(( (used_kb * 100) / (total_kb + 1) ))

    # --- CONTENT RENDERING ---
    if [ "$LAYOUT" = "double" ]; then
        # CPU
        move_cursor 7 2
        echo "${BOLD}CPU USAGE${RESET}"
        move_cursor 8 2
        printf "%3s%% " "$CPU_USAGE"
        draw_bar "$CPU_USAGE" 30
        
        # Memory
        move_cursor 10 2
        echo "${BOLD}MEMORY USAGE${RESET}"
        move_cursor 11 2
        printf "%3s%% " "$MEM_PCT"
        draw_bar "$MEM_PCT" 30
        echo " ($MEM_USED / $MEM_TOTAL)"
        
        # Services
        move_cursor 13 2
        echo "${BOLD}SERVICE STATUS${RESET}"
        svc_row=14
        for svc in "${SERVICES[@]}"; do
            systemctl is-active --quiet "$svc" && status="${GREEN}● Active${RESET}" || status="${RED}● Inactive${RESET}"
            move_cursor $svc_row 2
            printf "%-15s %s" "$svc" "$status"
            svc_row=$((svc_row + 1))
        done

        # Network & Storage
        move_cursor 7 $((HALF_COLS + 2))
        echo "${BOLD}NETWORK & STORAGE${RESET}"
        move_cursor 8 $((HALF_COLS + 2))
        echo "Net ↓: ${GREEN}$RX_SPEED${RESET} ↑: ${BLUE}$TX_SPEED${RESET}"
        move_cursor 9 $((HALF_COLS + 2))
        echo "Disk R: ${GREEN}$R_SPEED${RESET} W: ${BLUE}$W_SPEED${RESET}"
        
        # Latency
        move_cursor 10 $((HALF_COLS + 2))
        PING_TARGET=${1:-8.8.8.8}
        ping -c 1 -W 1 "$PING_TARGET" &>/dev/null && \
            latency=$(ping -c 1 -W 1 "$PING_TARGET" | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}') && \
            echo "Ping ($PING_TARGET): ${CYAN}${latency} ms${RESET}" || \
            echo "Ping ($PING_TARGET): ${RED}Offline${RESET}"
        
        # Disk Usage
        move_cursor 11 $((HALF_COLS + 2))
        echo "${BOLD}DISK UTILIZATION${RESET}"
        move_cursor 12 $((HALF_COLS + 2))
        draw_bar "$disk_pct" 20 
        echo " $disk_pct% ($((used_kb/1048576))G/$((total_kb/1048576))G)"

        # Footers (CPU vs MEM)
        PROCESS_ROW=22
        move_cursor $((PROCESS_ROW - 1)) 0
        for ((i=0; i<COLS; i++)); do printf "─"; done
        
        move_cursor $PROCESS_ROW 2
        echo "${BOLD}TOP CPU PROCESSES${RESET}"
        move_cursor $((PROCESS_ROW + 1)) 2
        printf "%-8s %-15s %-6s" "PID" "CMD" "%CPU"
        
        row=$((PROCESS_ROW + 2))
        ps -eo pid,comm,pcpu --sort=-pcpu | head -n 6 | tail -n 5 | while read -r pid comm pcpu; do
            move_cursor $row 2
            printf "%-8s %-15s %-6s" "$pid" "${comm:0:15}" "$pcpu"
            row=$((row + 1))
        done

        move_cursor $PROCESS_ROW $((HALF_COLS + 2))
        echo "${BOLD}TOP MEM PROCESSES${RESET}"
        move_cursor $((PROCESS_ROW + 1)) $((HALF_COLS + 2))
        printf "%-8s %-15s %-6s" "PID" "CMD" "%MEM"
        
        row=$((PROCESS_ROW + 2))
        ps -eo pid,comm,pmem --sort=-pmem | head -n 6 | tail -n 5 | while read -r pid comm pmem; do
            move_cursor $row $((HALF_COLS + 2))
            printf "%-8s %-15s %-6s" "$pid" "${comm:0:15}" "$pmem"
            row=$((row + 1))
        done
    else
        # Single Column Layout
        curr_row=6
        move_cursor $curr_row 2 && echo "System State: ${CYAN}$SYS_STATE${RESET}" && curr_row=$((curr_row+2))
        move_cursor $curr_row 2 && echo "CPU:" && move_cursor $((curr_row+1)) 2 && draw_bar "$CPU_USAGE" 40 && curr_row=$((curr_row+2))
        move_cursor $curr_row 2 && echo "MEM: ($MEM_USED/$MEM_TOTAL)" && move_cursor $((curr_row+1)) 2 && draw_bar "$MEM_PCT" 40 && curr_row=$((curr_row+3))
        move_cursor $curr_row 2 && echo "Net ↓$RX_SPEED ↑$TX_SPEED | Disk R$R_SPEED W$W_SPEED" && curr_row=$((curr_row+2))
        move_cursor $curr_row 2 && echo "DISK USAGE:" && move_cursor $((curr_row+1)) 2 && draw_bar "$disk_pct" 40 && echo " $disk_pct%" && curr_row=$((curr_row+3))
        
        move_cursor $curr_row 2 && echo "${BOLD}TOP PROCESSES (CPU)${RESET}" && curr_row=$((curr_row+1))
        ps -eo pid,comm,pcpu --sort=-pcpu | head -n 4 | tail -n 3 | while read -r pid comm pcpu; do
            move_cursor $curr_row 2 && printf "%-8s %-15s %-6s" "$pid" "${comm:0:15}" "$pcpu"
            curr_row=$((curr_row+1))
        done
    fi

    # Footer
    move_cursor $((ROWS-1)) 2
    echo "${WHITE}Press Ctrl+C to exit${RESET}"

    sleep 10
done
