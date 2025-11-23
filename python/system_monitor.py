"""
System Monitor Script
Checks CPU and RAM usage and alerts if thresholds are exceeded.
Usage: python system_monitor.py --config ../config/system_config.yaml
"""

import argparse
import yaml
import psutil
import sys
import os

def load_config(config_path):
    """Load configuration from YAML file."""
    if not os.path.exists(config_path):
        print(f"Error: Config file not found at {config_path}")
        sys.exit(1)
    
    with open(config_path, 'r') as file:
        try:
            return yaml.safe_load(file)
        except yaml.YAMLError as e:
            print(f"Error parsing YAML config: {e}")
            sys.exit(1)

def check_system_stats(config):
    """Check system statistics against thresholds."""
    cpu_threshold = config.get('cpu_threshold', 80)
    ram_threshold = config.get('ram_threshold', 85)
    
    # Get current stats
    cpu_usage = psutil.cpu_percent(interval=1)
    ram_usage = psutil.virtual_memory().percent
    
    issues_found = False
    
    print(f"Current Status: CPU: {cpu_usage}% | RAM: {ram_usage}%")
    
    if cpu_usage > cpu_threshold:
        print(f"ALERT: High CPU Usage detected! Current: {cpu_usage}% (Threshold: {cpu_threshold}%)")
        issues_found = True
        
    if ram_usage > ram_threshold:
        print(f"ALERT: High RAM Usage detected! Current: {ram_usage}% (Threshold: {ram_threshold}%)")
        issues_found = True
        
    if not issues_found:
        print("System health is within normal limits.")

def main():
    parser = argparse.ArgumentParser(description="System Resource Monitor")
    parser.add_argument("--config", required=True, help="Path to configuration YAML file")
    args = parser.parse_args()
    
    config = load_config(args.config)
    check_system_stats(config)

if __name__ == "__main__":
    main()
