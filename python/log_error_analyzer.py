import yaml
import os

def analyze_logs():
    try:
        with open("config/log_config.yaml", "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print("Config file not found: config/log_config.yaml")
        return

    log_file_path = config.get("log_file")
    keywords = config.get("keywords", [])

    if not log_file_path:
        print("No log file specified in config.")
        return

    if not os.path.exists(log_file_path):
        print(f"Log file not found: {log_file_path}")
        # Create a dummy file for testing if it doesn't exist
        with open(log_file_path, "w") as f:
            f.write("2023-10-27 10:00:00 INFO Starting application\n")
            f.write("2023-10-27 10:01:00 ERROR Connection failed\n")
            f.write("2023-10-27 10:02:00 CRITICAL Database down\n")
        print(f"Created dummy log file at {log_file_path} for testing.")

    print(f"Scanning {log_file_path} for keywords: {keywords}")
    print("-" * 60)

    try:
        with open(log_file_path, "r") as f:
            for line_num, line in enumerate(f, 1):
                for keyword in keywords:
                    if keyword in line:
                        print(f"Line {line_num}: {line.strip()}")
                        break
    except Exception as e:
        print(f"Error reading log file: {e}")

if __name__ == "__main__":
    analyze_logs()
