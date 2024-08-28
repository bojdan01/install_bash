#!/bin/bash

# Aktualizace systému
sudo apt update && sudo apt upgrade -y

# Instalace Apache2
sudo apt install apache2 -y

# Instalace PHP a potřebných modulů
sudo apt install php libapache2-mod-php php-mysql -y

# Instalace MariaDB
sudo apt install mariadb-server -y

# Zabezpečení instalace MariaDB s nastavením hesla pro root
echo "Spuštění mysql_secure_installation pro zabezpečení MariaDB."
sudo mysql_secure_installation

# Nastavení vzdáleného přístupu pro MariaDB
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Restart MariaDB
sudo systemctl restart mariadb

# Vytvoření uživatele root pro vzdálený přístup s nastaveným heslem
echo "Zadejte heslo pro uživatele root, které jste nastavili při mysql_secure_installation:"
read -sp 'Heslo pro root: ' root_password

sudo mysql -u root -p"$root_password" <<EOF
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$root_password' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
EOF

# Instalace phpMyAdmin
sudo apt install phpmyadmin -y

# Nastavení phpMyAdmin (propojení s Apache)
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Vytvoření uživatele phpmyadmin pro MariaDB
sudo mysql -u root -p"$root_password" <<EOF
CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'phpmyadmin_heslo';
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'phpmyadmin'@'localhost';
GRANT ALL PRIVILEGES ON \`phpmyadmin\_%\`.* TO 'phpmyadmin'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Úprava konfigurace phpMyAdmin pro povolení všech IP
sudo sed -i "s/Require ip/Require all granted/" /etc/apache2/conf-available/phpmyadmin.conf

# Restart Apache pro uplatnění změn
sudo systemctl restart apache2

# Nastavení firewallu (pokud je potřeba)
sudo ufw allow 3306/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

echo "Instalace a konfigurace je dokončena!"
echo "Nyní můžete přistupovat k phpMyAdmin na http://[IP adresa Raspberry Pi]/phpmyadmin"


