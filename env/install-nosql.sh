#!/bin/bash
echo "installing noSQL/SQL dependencies..."
sudo pacman -S memcached mariadb redis
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl restart mysqld.service
/usr/bin/mysql_secure_installation
sudo systemctl enable mysqld.service
sudo systemctl enable redis.service 
sudo systemctl enable memcached.service 
sudo systemctl start redis.service 
sudo systemctl start memcached.service 

