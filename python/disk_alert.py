import shutil

THRESHOLD = 80
total, used, free = shutil.disk_usage("/")
percent = used / total * 100

if percent > THRESHOLD:
    print(f"[CRITICAL] Disk usage {percent:.2f}% > {THRESHOLD}%")
else:
    print(f"[OK] Disk usage {percent:.2f}%")
