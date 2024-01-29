FROM ubuntu:latest
ENV TZ=America/NewYork
ARG DEBIAN_FRONTEND=noninteractive
#Tweaks to give httpd/php write permmission
RUN usermod -u 1000 www-data && usermod -G staff www-data && \
    useradd -r mysql && usermod -G staff mysql && \
    groupmod -g $((50 + 10000)) $(getent group 50 | cut -d: -f1) && \
    groupmod -g 50 staff
#Install needed packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y apt-utils wget python3-pip wget phpmyadmin curl git libapache2-mod-php mysql-server php-mysql python3-setuptools php-xdebug && \
    apt-get -y autoremove && apt-get -y clean && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf
# Install supervisor 4
RUN pip install supervisor
# RUN curl -L https://pypi.io/packages/source/s/supervisor/supervisor-${SUPERVISOR_VERSION}.tar.gz | tar xvz && \
#   cd supervisor-${SUPERVISOR_VERSION}/ && \
#   python3 setup.py install

# Add image configuration and scripts
ADD supporting_files/start-apache2.sh /start-apache2.sh
ADD supporting_files/start-mysqld.sh /start-mysqld.sh
ADD supporting_files/run.sh /run.sh
RUN chmod 755 /*.sh
ADD supporting_files/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supporting_files/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supporting_files/supervisord.conf /etc/supervisor/supervisord.conf
# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD supporting_files/create_mysql_users.sh /create_mysql_users.sh
ADD supporting_files/restore_drupaldb.sh /restore_drupaldb.sh
RUN chmod 755 /create_mysql_users.sh
RUN chmod 755 /restore_drupaldb.sh
# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

ENV MYSQL_PASS:-$(pwgen -s 12 1)
# config to enable .htaccess
ADD supporting_files/apache_default /etc/apache2/sites-available/000-default.conf
ADD supporting_files/apache2.conf /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
RUN cd /app && wget "https://wordpress.org/latest.tar.gz" && tar -xzf /app/latest.tar.gz
#ADD app/ /app

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app and MySql
#VOLUME  ["/var/lib/mysql", "/app" ]

#adduer to get around mysql start problem
RUN mkdir /home/mysql && chown mysql:staff /home/mysql
#Restore MySQL backup
#RUN /etc/init.d/mysql start
#RUN /bin/bash -c "/usr/bin/mysqld_safe --skip-grant-tables &" && sleep 10 && mysql -u root -e "CREATE DATABASE drupal"
#RUN mysql -u root drupal < /app/drupaldbmy.sql

EXPOSE 80 3306
#CMD ["/run.sh"]
ENTRYPOINT [ "/run.sh" ]
