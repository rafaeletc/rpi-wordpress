FROM pabrahamsson/rpi-php

MAINTAINER Petter Abrahamsson <petter@jebus.nu>

RUN apk update && apk add bash sed

RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=60'; \
	echo 'opcache.fast_shutdown=1'; \
	echo 'opcache.enable_cli=1'; \
    } > /etc/php/conf.d/opcache-recommended.ini

ENV WORDPRESS_VERSION 4.4
ENV WORDPRESS_SHA1 d647a77c63f2ba06578f7747bd4ac295e032f57a

RUN mkdir -p /usr/src

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
        && gunzip wordpress.tar.gz \
	&& tar -xf wordpress.tar -C /usr/src/ \
	&& rm wordpress.tar \
	&& chown -R apache:apache /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
