import requests
import yaml
from logger import setup_logger

# Initialize logger
logger = setup_logger("api_status_checker")

def check_api_status():
    try:
        cfg = yaml.safe_load(open("config/monitor_urls.yaml"))
    except FileNotFoundError:
        logger.error("Configuration file not found: config/monitor_urls.yaml")
        return
    except Exception as e:
        logger.error(f"Error loading configuration: {e}")
        return

    for item in cfg.get("urls", []):
        name = item.get("name", "Unknown")
        url = item.get("url")
        
        if not url:
            logger.warning(f"Skipping item with no URL: {item}")
            continue

        try:
            r = requests.get(url, timeout=5)
            logger.info(f"{name} - Status: {r.status_code} - Latency: {r.elapsed.total_seconds()}s")
        except requests.exceptions.RequestException as e:
            logger.error(f"{name} - DOWN - Error: {e}")

if __name__ == "__main__":
    check_api_status()
