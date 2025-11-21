import shutil
import yaml

def check_disk_space():
    try:
        with open("config/disk_config.yaml", "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print("Config file not found: config/disk_config.yaml")
        return

    path = config.get("path", "/")
    threshold = config.get("threshold_percent", 80)

    try:
        total, used, free = shutil.disk_usage(path)
        
        total_gb = total / (2**30)
        used_gb = used / (2**30)
        free_gb = free / (2**30)
        percent_used = (used / total) * 100

        print(f"Disk Usage for {path}:")
        print(f"Total: {total_gb:.2f} GB")
        print(f"Used:  {used_gb:.2f} GB ({percent_used:.1f}%)")
        print(f"Free:  {free_gb:.2f} GB")
        
        if percent_used > threshold:
            print(f"ALERT: Disk usage exceeds threshold of {threshold}%!")
        else:
            print("Status: OK")

    except Exception as e:
        print(f"Error checking disk space: {e}")

if __name__ == "__main__":
    check_disk_space()
