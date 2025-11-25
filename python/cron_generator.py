import yaml
import os
import sys
from logger import setup_logger

logger = setup_logger("cron_generator")

def generate_cron_jobs():
    try:
        with open("config/cron_jobs.yaml", "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        logger.error("Config file not found: config/cron_jobs.yaml")
        return
    except Exception as e:
        logger.error(f"Error loading configuration: {e}")
        return

    print("### Generated Crontab Entries ###")
    print("# Copy and paste these into your crontab (crontab -e)")
    print("")

    cwd = os.getcwd()
    python_path = sys.executable

    for job in config.get("jobs", []):
        name = job.get("name", "Unnamed Job")
        schedule = job.get("schedule", "0 * * * *")
        script = job.get("script")
        args = job.get("args", "")
        
        if not script:
            logger.warning(f"Skipping job '{name}' - No script specified.")
            continue

        # Determine full path to script
        script_path = os.path.abspath(script)
        
        if script.endswith(".py"):
            command = f"{python_path} {script_path} {args}"
        elif script.endswith(".sh"):
            command = f"bash {script_path} {args}"
        else:
            command = f"{script_path} {args}"

        print(f"# {name}")
        print(f"{schedule} {command}")
        print("")

if __name__ == "__main__":
    generate_cron_jobs()
