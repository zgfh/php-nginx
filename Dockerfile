############################################################
# Dockerfile to build CentOS,Nginx installed  Container
# Based on CentOS
############################################################

# Set the base image to Ubuntu
FROM centos:7

ENV nginxversion="1.12.2-1" \
    os="centos" \
    osversion="7" \
    elversion="7_4" \
    php_version="7.1.18"
# Installing nginx
RUN yum install -y epel-release; yum install -y wget openssl sed \
    && yum -y autoremove \
    && yum clean all \
    && wget http://nginx.org/packages/$os/$osversion/x86_64/RPMS/nginx-$nginxversion.el$elversion.ngx.x86_64.rpm \
    && rpm -iv nginx-$nginxversion.el$elversion.ngx.x86_64.rpm

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Installing PHP
RUN yum install -y autoconf libtool bison libxml2-devel bzip2-devel \
    libcurl-devel libpng-devel libicu-devel gcc-c++ \
    libwebp-devel libjpeg-devel openssl-devel openldap openldap-devel \
    libxslt-devel \
    libjpeg libpng  freetype freetype-devel libxml2 zlib zlib-devel glibc \
    glibc-devel glib2 glib2-devel ncurses-devel curl curl-devel \
    e2fsprogs krb5-devel libidn libidn-devel automake make enchant-devel \
    libXpm-devel libc-client-devel aspell-devel readline-devel net-snmp-devel \
    unixODBC-devel libvpx-devel db4-devel gmp-devel sqlite-devel pcre-devel \
    mysql-devel libedit-devel libtidy-devel \
    && yum -y autoremove \
    && yum clean all\
    && wget ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/attic/libmcrypt/libmcrypt-2.5.7.tar.gz \
    && tar -zxvf libmcrypt-2.5.7.tar.gz && cd libmcrypt-2.5.7 &&./configure && make && make install \
    && cd .. && rm -rf libmcrypt-2.5.7 \
    && cp -frp /usr/lib64/libldap* /usr/lib/ \
    && wget https://github.com/php/php-src/archive/php-$php_version.tar.gz -O php-$php_version.tar.gz \
    && tar -zxvf php-$php_version.tar.gz
RUN groupadd -f -g 82 www-data && adduser -u 82 -g www-data www-data \
    && export LD_LIBRARY_PATH=/usr/local/mysql/lib:/lib/:/usr/lib/:/usr/local/lib \
    && cd php-src-php-$php_version \
    && ./buildconf --force && ./configure \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-libdir=lib64 \
    --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr --with-xpm-dir=/usr\
    --enable-pdo \
    --with-pdo-sqlite \
    --with-pdo-mysql=mysqlnd \
    --with-freetype-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib \
    --enable-calendar \
    --enable-xml \
    --disable-rpath \
    --enable-bcmath \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --with-curl \
    --enable-mbregex \
    --enable-mbstring \
    --with-mcrypt \
    --with-gd \
    --enable-gd-native-ttf \
    --with-openssl \
    --with-mhash \
    --enable-pcntl \
    --enable-sockets \
    --enable-opcache \
    --with-ldap \
    --with-ldap-sasl \
    --with-xmlrpc \
    --enable-zip \
    --enable-soap \
    --with-pear \
    --enable-fpm \
    --enable-intl \
    --with-snmp \
    --with-gettext \
    --enable-exif \
    --with-bz2 \
    --enable-sysvmsg \
    --enable-sysvshm \
    --enable-ftp \
    --with-imap \
    --with-imap-ssl \
    --with-kerberos \
    --with-readline \
    --with-libedit \
    --with-pspell \
    --with-tidy \
    --with-enchant \
    --disable-fileinfo \
    --with-xsl \
    --enable-embed=shared \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    && make clean && make && make install && cd .. && rm -rf php-src-php-$php_version


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