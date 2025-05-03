#!/bin/bash

echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

echo "Instalando dependências..."
sudo apt install apache2 mariadb-server php php-mysql php-gmp php-curl php-mbstring php-xml php-ldap php-zip php-bcmath php-gd unzip git -y

echo "Clonando repositório do phpIPAM..."
cd /var/www/html
sudo git clone https://github.com/phpipam/phpipam.git
sudo chown -R www-data:www-data phpipam

echo "Criando banco de dados e usuário..."
sudo mysql -e "CREATE DATABASE phpipam;"
sudo mysql -e "CREATE USER 'phpipamuser'@'localhost' IDENTIFIED BY 'SenhaForte123!';"
sudo mysql -e "GRANT ALL PRIVILEGES ON phpipam.* TO 'phpipamuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Importando esquema do banco..."
cd /var/www/html/phpipam/db
mysql -u phpipamuser -p'SenhaForte123!' phpipam < SCHEMA.sql

echo "Configurando Apache..."
cat <<EOL | sudo tee /etc/apache2/sites-available/phpipam.conf
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html/phpipam
    <Directory /var/www/html/phpipam>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/phpipam_error.log
    CustomLog \${APACHE_LOG_DIR}/phpipam_access.log combined
</VirtualHost>
EOL

sudo a2ensite phpipam.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

echo "Instalação concluída. Acesse: http://<seu_ip>/ para configurar o phpIPAM."
