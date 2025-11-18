import os, time, yaml

cfg = yaml.safe_load(open("config/sftp_watch.yaml"))
path = cfg["watch_path"]

seen = set(os.listdir(path))

while True:
    current = set(os.listdir(path))
    new = current - seen
    if new:
        print("New files:", new)
    seen = current
    time.sleep(cfg.get("interval", 5))
