# # -------------------
# # Build Stage 1 (npm)
# # -------------------
# FROM node:14 AS appbuild

# ARG PYTHON_VERSION=2.7.18
# ENV PYTHONIOENCODING=UTF-8
# ENV LANG=C.UTF-8


# RUN apk add --no-cache ca-certificates

# RUN apk update && apk add --no-cache p7zip curl bash make gcc g++ musl-dev binutils autoconf automake libtool pkgconfig check-dev file patch

# RUN set -ex \
#     && apk add --no-cache --virtual .fetch-deps gnupg tar xz \
#     && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
#     && mkdir -p /usr/src/python \
#     && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
#     && rm python.tar.xz \
#     && apk add --no-cache --virtual .build-deps  bzip2-dev coreutils dpkg-dev dpkg expat-dev findutils gcc gdbm-dev libc-dev libffi-dev libnsl-dev libtirpc-dev linux-headers make ncurses-dev openssl-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev zlib-dev \
#     && apk del .fetch-deps \
#     && cd /usr/src/python \
#     && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
#     && ./configure --build="$gnuArch" --enable-optimizations --enable-option-checking=fatal --enable-shared --enable-unicode=ucs4 --with-system-expat --with-system-ffi \
#     && make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" PROFILE_TASK='-m test.regrtest --pgo test_array test_base64 test_binascii test_binhex test_binop test_bytes test_c_locale_coercion test_class test_cmath test_codecs test_compile test_complex test_csv test_decimal test_dict test_float test_fstring test_hashlib test_io test_iter test_json test_long test_math test_memoryview test_pickle test_re test_set test_slice test_struct test_threading test_time test_traceback test_unicode ' \
#     && make install \
#     && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' '; \
#     ' | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' | xargs -rt apk add --no-cache --virtual .python-rundeps \
#     && apk del .build-deps \
#     && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' + \
#     && rm -rf /usr/src/python \
#     && python2 --version

# ENV PYTHON_PIP_VERSION=20.0.2
# ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/d59197a3c169cef378a22428a3fa99d33e080a5d/get-pip.py

# RUN set -ex \
#     && wget -O get-pip.py "$PYTHON_GET_PIP_URL" \
#     && python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" \
#     && pip --version \
#     && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' + \
#     && rm -f get-pip.py
# # RUN openssl version

# # RUN wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz
# # RUN tar xvzf openssl-1.1.1w.tar.gz && cd openssl-1.1.1w && ./config --prefix=/opt/openssl --openssldir=/opt/openssl/ssl && make && make install
# # RUN mv /usr/bin/openssl /usr/bin/openssl.old  && ln -s /opt/openssl/bin/openssl /usr/bin/openssl && ln -s /etc/ssl/certs/*.* /opt/openssl/ssl/certs/

# # #Download OpenSSL
# # cd /usr/local/src/
# # wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz
# # tar -xf openssl-1.1.1c.tar.gz
# # cd openssl-1.1.1c
# # #Install OpenSSL
# # ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
# # make
# # make test
# # make install

# # #Configure OpenSSL Shared Libraries
# # cd /etc/ld.so.conf.d/
# # nano openssl-1.1.1c.conf
# #   /usr/local/ssl/lib

# # #Save and exit
# # ldconfig -v
# # #Configure OpenSSL Binary
# # mv /usr/bin/c_rehash /usr/bin/c_rehash.backup
# # mv /usr/bin/openssl /usr/bin/openssl.backup
# # nano /etc/environment
# #   PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/ssl/bin"
# # #Ensure to save before you exit
# # source /etc/environment
# # echo $PATH

# # # Build Python from source
# # RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
# #     && tar --extract -f Python-$PYTHON_VERSION.tgz \
# #     && cd ./Python-$PYTHON_VERSION/ \
# #     && ./configure --enable-optimizations --prefix=/usr/local \
# #     && make && make install \
# #     && cd ../ \
# #     && rm -r ./Python-$PYTHON_VERSION*

# # RUN python -v -c "import hashlib" 2> output.txt
# RUN python --version

# WORKDIR /usr/src/app

# COPY ./package.json ./

# RUN npm install 


# COPY . ./
# RUN mkdir node_modules/normalize.css \
#     && mkdir -p node_modules/mini-css-extract-plugin/node_modules/normalize.css \
#     && mkdir -p node_modules/postcss-loader/node_modules/normalize.css \
#     && cp node_modules2/normalize.css/normalize.css node_modules/normalize.css/normalize.css \
#     && cp node_modules2/normalize.css/normalize.css node_modules/postcss-loader/node_modules/normalize.css/normalize.css \
#     && cp node_modules2/normalize.css/normalize.css node_modules/mini-css-extract-plugin/node_modules/normalize.css/normalize.css
# RUN npm run build:prod
# # RUN npm run build


# ------------------------
# Build Stage 2 (composer)
# ------------------------
FROM jitesoft/composer:7.4 AS apibuild

WORKDIR /app

COPY ./src/api ./
RUN composer install


# --------------------------
# Build Stage 3 (php-apache)
# This build takes the production build from staging builds
# --------------------------
FROM php:7.4-apache

ENV PROJECT /var/www/html

# RUN apt-cache search php-sqlite3
# RUN apt-get update && apt-get install -y sqlite3 php-sqlite3
# RUN docker-php-ext-install sqlite
RUN a2enmod rewrite expires
# RUN docker-php-ext-install pdo_mysql

# RUN pecl install xdebug && docker-php-ext-enable xdebug
# COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR $PROJECT
COPY docker/apache.conf /usr/local/apache2/conf/httpd.conf
COPY dist ./
RUN rm -rf ./api/*
COPY --from=apibuild /app ./api/
RUN chmod 777 ./api
EXPOSE 80
