import mysql.connector
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Database connection settings
db_config = {
    'host': '127.0.0.1',      # or your host
    'user': 'root',
    'password': 'Akki791@',
    'database': 'CafeDB'      # or your database name
}

# Email settings
smtp_server = "smtp.google.com"  # e.g., smtp.gmail.com
smtp_port = 587                        # typically 587 for TLS
smtp_username = "akhileshchinta791@google.com"
smtp_password = "Akki791@"
sender_email = "anathalakshmichinta67@google.com"
receiver_email = "akhileshchinta791@google.com"

# Threshold for low stock
LOW_STOCK_THRESHOLD = 10

def get_low_stock():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT Material_Id, Stock 
            FROM inventory_backup 
            WHERE Stock < %s;
        """
        cursor.execute(query, (LOW_STOCK_THRESHOLD,))
        low_stock_data = cursor.fetchall()
        cursor.close()
        conn.close()
        return low_stock_data
    except mysql.connector.Error as err:
        print("Error: {}".format(err))
        return []

def send_email_alert(low_stock_data):
    # Construct the email content
    subject = "Low Stock Alert"
    body = "The following materials have low stock:\n\n"
    for row in low_stock_data:
        body += f"Material_Id: {row['Material_Id']}, Stock: {row['Stock']}\n"
    
    # Create the MIME message
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject
    
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()  # Enable TLS
        server.login(smtp_username, smtp_password)
        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()
        print("Email alert sent successfully.")
    except Exception as e:
        print("Error sending email:", e)

def main():
    low_stock_data = get_low_stock()
    if low_stock_data:
        print("Low stock found. Sending email alert...")
        send_email_alert(low_stock_data)
    else:
        print("Stock levels are sufficient. No alert needed.")

if __name__ == "__main__":
    main()


