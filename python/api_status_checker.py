import requests, yaml

cfg = yaml.safe_load(open("config/monitor_urls.yaml"))

for item in cfg["urls"]:
    try:
        r = requests.get(item["url"], timeout=5)
        print(item["name"], r.status_code, "latency:", r.elapsed.total_seconds())
    except Exception as e:
        print(item["name"], "DOWN", e)
