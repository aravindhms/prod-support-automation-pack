import subprocess

SERVICES = ["nginx", "sshd"]
for svc in SERVICES:
    result = subprocess.run(["systemctl", "is-active", svc], capture_output=True, text=True)
    status = result.stdout.strip()
    print(f"{svc}: {status}")
