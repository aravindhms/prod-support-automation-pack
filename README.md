<div align="center">

# 🚀 Prod Support Automation Pack  
### Python + Bash Automation Toolkit for L2 Support & SRE

A curated collection of **production-ready automation scripts** used in  
Application Support, Site Reliability Engineering (SRE), and DevOps environments.

---

### 🛡️ Built for:
**Application Support (L1/L2)** • **Production Support** • **SRE Beginners**  
**Unix Engineers** • **Ops Teams** • **Automation Engineers**

---

![Status](https://img.shields.io/badge/Project-Active-success?style=flat-square)
![Python](https://img.shields.io/badge/Python-3.9+-blue?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-Scripts-green?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

</div>

---

# 📂 Project Structure

```
prod-support-automation-pack/
├── python/     → Python automation scripts  
├── shell/      → Shell scripts for quick ops  
├── config/     → YAML configuration files  
└── README.md
```

---

# ⚙️ Features (Why this repo is awesome)

### 🔍 **Log Monitoring**
- Detects ORA errors, SQLSTATE, timeouts  
- Real-time streaming alert engine  
- Pattern-based matching using YAML config  

### 💾 **Disk Monitoring**
- Auto alerts on threshold breach (Python + Shell)  
- Lightweight & cron-friendly  

### 🏥 **Service Health Checks**
- systemctl-based health monitoring  
- JSON/text output for dashboards  

### 📡 **API Status & Latency Checks**
- Tracks uptime  
- Response time  
- Error detection (

)

### 🔁 **SFTP File Watcher**
- Detects dropped files  
- Useful for integration teams  

### 📦 **File Tools**
- Duplicate detection using MD5 hashing  
- Safe cleanup scripts  

---

# 🧰 Included Scripts

### 🐍 Python Tools
| Script | Purpose |
|--------|---------|
| `log_monitor.py` | Monitor logs for critical patterns |
| `disk_alert.py` | Disk usage monitoring |
| `duplicate_finder.py` | Detect duplicate files |
| `service_checker.py` | systemctl service health |
| `api_status_checker.py` | API uptime + latency |
| `sql_validator.py` | Pretty-format SQL |
| `file_watcher.py` | Monitor directories for file creation |

---

### 🐚 Shell Tools
| Script | Purpose |
|--------|---------|
| `tail_pattern.sh` | Follow logs with grep pattern |
| `cleanup_logs.sh` | Auto-delete old logs |
| `disk_usage_alert.sh` | Simple disk alert script |
| `service_health.sh` | Quick service status checker |
| `sftp_file_monitor.sh` | Watch SFTP folder for new files |

---

# 🚀 Quick Start

### **Clone the repo**
```bash
git clone https://github.com/<your-username>/prod-support-automation-pack.git
cd prod-support-automation-pack
```

---

## 🐍 Run Python Scripts
### Install requirements:
```bash
pip install -r requirements.txt
```

Example: log monitor  
```bash
python3 python/log_monitor.py --config config/log_patterns.yaml
```

---

## 🐚 Run Shell Scripts
Make executable:
```bash
chmod +x shell/*.sh
```

Example:
```bash
./shell/disk_usage_alert.sh
```

---

# 🎯 Roadmap
- 🔗 Slack/Teams alert integration  
- 📊 Web-based dashboard  
- 🕒 Scheduler support  
- 📨 Email alert system  
- 🧪 Test suite  

---

# 🤝 Contributing
PRs are welcome!  
If you fix a bug or add a new script, feel free to open a pull request.

---

# 📄 License
**MIT License** — free to use, modify, share.

---

<div align="center">

### ⭐ If you find this useful, please consider giving it a star!

</div>
