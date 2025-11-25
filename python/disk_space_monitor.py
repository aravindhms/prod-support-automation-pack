import shutil
import yaml
from logger import setup_logger

# Initialize logger
logger = setup_logger("disk_space_monitor")

def check_disk_space():
    try:
        with open("config/disk_config.yaml", "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        logger.error("Config file not found: config/disk_config.yaml")
        return
    except Exception as e:
        logger.error(f"Error loading configuration: {e}")
        return

    path = config.get("path", "/")
    threshold = config.get("threshold_percent", 80)

    try:
        total, used, free = shutil.disk_usage(path)
        
        total_gb = total / (2**30)
        used_gb = used / (2**30)
        free_gb = free / (2**30)
        percent_used = (used / total) * 100

        logger.info(f"Disk Usage for {path}:")
        logger.info(f"Total: {total_gb:.2f} GB")
        logger.info(f"Used:  {used_gb:.2f} GB ({percent_used:.1f}%)")
        logger.info(f"Free:  {free_gb:.2f} GB")
        
        if percent_used > threshold:
            logger.warning(f"ALERT: Disk usage exceeds threshold of {threshold}%!")
        else:
            logger.info("Status: OK")

    except Exception as e:
        logger.error(f"Error checking disk space: {e}")

if __name__ == "__main__":
    check_disk_space()
