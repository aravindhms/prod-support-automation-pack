import requests
import smtplib
from email.mime.text import MIMEText
from logger import setup_logger

logger = setup_logger("alert_notifier")

def send_slack_message(webhook_url, message):
    """
    Sends a message to a Slack channel via Webhook.
    """
    if not webhook_url:
        logger.warning("Slack Webhook URL not provided. Skipping alert.")
        return

    payload = {"text": message}
    try:
        response = requests.post(webhook_url, json=payload, timeout=5)
        if response.status_code == 200:
            logger.info("Slack alert sent successfully.")
        else:
            logger.error(f"Failed to send Slack alert: {response.status_code} - {response.text}")
    except Exception as e:
        logger.error(f"Error sending Slack alert: {e}")

def send_teams_message(webhook_url, message):
    """
    Sends a message to Microsoft Teams via Webhook.
    """
    if not webhook_url:
        logger.warning("Teams Webhook URL not provided. Skipping alert.")
        return

    payload = {"text": message}
    try:
        response = requests.post(webhook_url, json=payload, timeout=5)
        if response.status_code == 200:
            logger.info("Teams alert sent successfully.")
        else:
            logger.error(f"Failed to send Teams alert: {response.status_code} - {response.text}")
    except Exception as e:
        logger.error(f"Error sending Teams alert: {e}")

def send_email(smtp_server, port, sender, recipients, subject, body, password=None):
    """
    Sends an email alert.
    """
    if not smtp_server or not recipients:
        logger.warning("SMTP config or recipients missing. Skipping email alert.")
        return

    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = ", ".join(recipients)

    try:
        with smtplib.SMTP(smtp_server, port) as server:
            server.starttls()
            if password:
                server.login(sender, password)
            server.sendmail(sender, recipients, msg.as_string())
        logger.info("Email alert sent successfully.")
    except Exception as e:
        logger.error(f"Error sending email alert: {e}")
