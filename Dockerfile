############################################################
# Dockerfile to build CentOS,Nginx installed  Container
# Based on CentOS
############################################################

# Set the base image to Ubuntu
FROM centos:7

ENV nginxversion="1.12.2-1" \
    os="centos" \
    osversion="7" \
    elversion="7_4"
# Installing nginx 
RUN yum install -y wget openssl sed &&\
    yum -y autoremove &&\
    yum clean all &&\
    wget http://nginx.org/packages/$os/$osversion/x86_64/RPMS/nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
    rpm -iv nginx-$nginxversion.el$elversion.ngx.x86_64.rpm 

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Installing PHP
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
RUN yum -y install php56w php56w-cli php56w-common php56w-fpm \
    yum -y autoremove &&\
    yum clean all 
# Installing PHP
RUN yum -y install php56w-bcmath php56w-dba php56w-devel php56w-embedded php56w-enchant php56w-gd php56w-imap php56w-interbase php56w-intl php56w-ldap php56w-mbstring php56w-mcrypt php56w-mssql php56w-mysql php56w-odbc php56w-opcache php56w-pdo php56w-pecl-apcu php56w-pecl-apcu-devel php56w-pecl-gearman php56w-pecl-geoip php56w-pecl-igbinary php56w-pecl-igbinary-devel php56w-pecl-imagick php56w-pecl-imagick-devel php56w-pecl-libsodium php56w-pecl-memcache php56w-pecl-memcached php56w-pecl-mongodb php56w-pecl-redis php56w-pecl-xdebug php56w-pgsql php56w-phpdbg php56w-process php56w-pspell php56w-recode php56w-snmp php56w-soap php56w-tidy php56w-xml php56w-xmlrpc \
    yum -y autoremove &&\
    yum clean all 

# Installing supervisor
RUN yum install -y python-setuptools
RUN easy_install pip
RUN pip install supervisor


# Adding the configuration file of the nginx
ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

# Adding the configuration file of the Supervisor
ADD supervisord.conf /etc/

# Adding the default file
ADD index.php /var/www/index.php
ADD php-fpm.conf /etc/php-fpm.conf
# Set the port to 80 
EXPOSE 80

# Executing supervisord
CMD ["supervisord", "-n"]
