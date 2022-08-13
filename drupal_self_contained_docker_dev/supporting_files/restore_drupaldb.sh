#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

echo "=> Creating MySQL stub database for drupal"

mysql -uroot -e "CREATE DATABASE drupal"
echo "=> Restoring Drupal Database"
mysql -u root drupal < /app/drupaldbmy.sql

echo "=> Done!"

mysqladmin -uroot shutdown