import ssl
import socket
import datetime
import yaml

def get_ssl_expiry_date(hostname, port):
    context = ssl.create_default_context()
    with socket.create_connection((hostname, port)) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as ssock:
            ssl_info = ssock.getpeercert()
            expiry_date_str = ssl_info['notAfter']
            expiry_date = datetime.datetime.strptime(expiry_date_str, '%b %d %H:%M:%S %Y %Z')
            return expiry_date

def main():
    try:
        with open("config/ssl_domains.yaml", "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print("Config file not found: config/ssl_domains.yaml")
        return

    print(f"{'Domain':<30} {'Days Left':<10} {'Status'}")
    print("-" * 50)

    for item in config["domains"]:
        host = item["host"]
        port = item.get("port", 443)
        try:
            expiry_date = get_ssl_expiry_date(host, port)
            days_left = (expiry_date - datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)).days
            status = "OK" if days_left > 30 else "WARNING" if days_left > 0 else "EXPIRED"
            print(f"{host:<30} {days_left:<10} {status}")
        except Exception as e:
            print(f"{host:<30} {'ERROR':<10} {e}")

if __name__ == "__main__":
    main()
