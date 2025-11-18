import time, re, yaml

def load_patterns():
    with open("config/log_patterns.yaml") as f:
        return yaml.safe_load(f)

def monitor(file, patterns):
    with open(file) as log:
        log.seek(0, 2)
        while True:
            line = log.readline()
            if not line:
                time.sleep(0.5)
                continue
            for p in patterns:
                if re.search(p["pattern"], line):
                    print(f"[ALERT] Pattern matched: {p['name']} | {line.strip()}")

if __name__ == "__main__":
    cfg = load_patterns()
    monitor(cfg["log_file"], cfg["patterns"])
