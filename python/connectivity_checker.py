import socket
import yaml
from logger import setup_logger

logger = setup_logger("connectivity_checker")

def check_connectivity():
    try:
        with open("config/connectivity.yaml", "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        logger.error("Config file not found: config/connectivity.yaml")
        return
    except Exception as e:
        logger.error(f"Error loading configuration: {e}")
        return

    for item in config.get("targets", []):
        host = item.get("host")
        port = item.get("port")
        name = item.get("name", f"{host}:{port}")

        if not host or not port:
            logger.warning(f"Skipping invalid target: {item}")
            continue

        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(3)
            result = sock.connect_ex((host, port))
            
            if result == 0:
                logger.info(f"{name} - Connection Successful ({host}:{port})")
            else:
                logger.error(f"{name} - Connection FAILED ({host}:{port}) - Error Code: {result}")
            
            sock.close()
        except Exception as e:
            logger.error(f"{name} - Error checking connection: {e}")

if __name__ == "__main__":
    check_connectivity()
