FROM php:7.2-zts-alpine

# squash the base image to remove environment variables and other immutable options
FROM scratch
COPY --from=0 / /

MAINTAINER Andrew Mackrodt <andrew@denimsoft.com>

# install packages
RUN apk add --no-cache \
        # interactive shell packages
        bash \
        git \
        htop \
        man \
        openssh \
        sudo \
        vim \
        # supervisord packages
        python2 \
        py-setuptools \
        # timezone data
        tzdata \
        # php extension runtime packages
        bzip2 \
        c-client \
        freetype \
        gmp \
        icu \
        imap \
        libjpeg-turbo \
        libpng \
        libxml2 \
        libxslt \
        pcre \
        postgresql-libs \
        tidyhtml \
    && apk add --no-cache --virtual .deps \
        autoconf \
        g++ \
        make \
        py2-pip \
    && pip install --no-cache-dir \
        supervisor \
        supervisor-stdout \
    && apk del --no-cache .deps \
    && echo -e "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/group

# install php extensions
RUN apk add --no-cache --virtual .deps \
        # build depdencies
        autoconf \
        g++ \
        make \
        # extension depdencies
        bzip2-dev \
        freetype-dev \
        gmp-dev \
        icu-dev \
        imap-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libxslt-dev \
        pcre-dev \
        postgresql-dev \
        tidyhtml-dev \
    && docker-php-ext-enable opcache \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && CFLAGS="-I/usr/src/php" docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) \
        bcmath \
        bz2 \
        exif \
        gd \
        gmp \
        imap \
        intl \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        shmop \
        simplexml \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        xmlrpc \
        xsl \
        zip \
    && apk del --no-cache .deps

# install pthreads from the master branch
RUN apk add --no-cache --virtual .deps autoconf g++ make \
    && curl -sSL https://github.com/krakjoe/pthreads/archive/master.zip -o /tmp/pthreads.zip \
    && unzip /tmp/pthreads.zip -d /tmp \
    && cd /tmp/pthreads-* \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/pthreads* \
    && docker-php-ext-enable pthreads \
    && apk del --no-cache .deps

# install debug extensions, not enabled by default
RUN apk add --no-cache --virtual .deps autoconf g++ make \
    && pecl install xdebug \
    && pecl install uopz \
    && apk del --no-cache .deps

# add composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY entrypoint.d/ /usr/local/etc/entrypoint.d/
COPY profile.d/ /etc/profile.d/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf

RUN mkdir -p /etc/supervisord.d/ \
    && ln -s /etc/profile.d/color_prompt /etc/profile.d/color_prompt.sh \
    && chmod a+x /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
