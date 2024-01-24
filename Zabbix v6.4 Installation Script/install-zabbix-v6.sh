#!/bin/bash

# Step 1: Go to the Zabbix download site
echo "1. Go to the Zabbix download site: https://www.zabbix.com/download"

# Step 2: Download and install Zabbix repository package
echo "2. Downloading and installing Zabbix repository package..."
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update -y

# Step 3: Install Zabbix Server, Frontend, Apache, SQL scripts, and Agent
echo "3. Installing Zabbix Server, Frontend, Apache, SQL scripts, and Agent..."
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# Step 4: Create initial database on MySQL
echo "4. Creating initial database on MySQL..."
mysql -uroot -p -e "CREATE DATABASE zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -uroot -p -e "CREATE USER zabbix@localhost IDENTIFIED BY 'password';"
mysql -uroot -p -e "GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost;"
mysql -uroot -p -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Step 5: Import initial schema and data
echo "5. Importing initial schema and data..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix 

# Step 6: Disable log_bin_trust_function_creators option
echo "6. Disabling log_bin_trust_function_creators option..."
mysql -uroot -p -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Step 7: Configure Zabbix server database
echo "7. Configuring Zabbix server database..."
sed -i 's/#DBPassword=/DBPassword=password/' /etc/zabbix/zabbix_server.conf

# Step 8: Configure Zabbix agent
echo "8. Configuring Zabbix agent..."
ZABBIX_SERVER_IP="YOUR_ZABBIX_SERVER_IP"
ZABBIX_SERVER_HOSTNAME="YOUR_ZABBIX_SERVER_HOSTNAME"
sed -i "s/Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=${ZABBIX_SERVER_HOSTNAME}/" /etc/zabbix/zabbix_agentd.conf

# Step 9: Restart Zabbix server, agent, and Apache
echo "9. Restarting Zabbix server, agent, and Apache..."
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

# Step 10: Open Zabbix UI web page
echo "10. Opening Zabbix UI web page..."
echo "Default URL for Zabbix UI (using Apache): http://your_host/zabbix"

echo "Steps to configure the UI after visiting http://your_host/zabbix:"
echo "- Click Next"
echo "- If all is OK, click Next Step"
echo "- Insert the password configured earlier while creating the Zabbix user"
echo "- Enter Zabbix server name and Default time zone as per your requirements"
echo "- Click Next Step"
echo ""
echo "You have successfully installed the Zabbix frontend."
echo "Username: Admin"
echo "Password: Zabbix"
