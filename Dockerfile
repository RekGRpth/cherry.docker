FROM rekgrpth/gost
ADD entrypoint.sh /
CMD [ "httpd", "-D", "FOREGROUND" ]
ENV GROUP=apache \
    USER=apache
VOLUME "${HOME}"
RUN set -ex \
    && mkdir -p "${HOME}" \
    && apk add --no-cache --virtual .build-deps \
        make \
        perl-utils \
    && cpan -i CGI/Deurl.pm \
    && apk del \
        perl-utils \
    && apk add --no-cache --virtual .cherry-rundeps \
        apache2 \
        apache2-ldap \
        apache2-ssl \
        coreutils \
        perl \
        perl-cgi \
        perl-cgi-session \
        perl-dbd-pg \
        perl-dbi \
        perl-yaml-syck \
    && apk del --no-cache .build-deps \
    && usermod --home "${HOME}" "${USER}" \
    && chmod +x /entrypoint.sh \
    && mkdir -p /run/apache2 \
    && rm -rf /var/www/localhost/htdocs && ln -sf "${HOME}/app" /var/www/localhost/htdocs \
    && rm -rf /var/www/logs && ln -sf "${HOME}/log" /var/www/logs \
    && sed -i "/^LogLevel/cLogLevel info" "/etc/apache2/httpd.conf" \
    && sed -i "s|#AddHandler cgi-script .cgi|AddHandler cgi-script .cgi|g" "/etc/apache2/httpd.conf" \
    && sed -i "s|#LoadModule rewrite|LoadModule rewrite|g" "/etc/apache2/httpd.conf" \
    && sed -i "s|#LoadModule cgi|LoadModule cgi|g" "/etc/apache2/httpd.conf" \
    && sed -i "s|#LoadModule suexec|LoadModule suexec|g" "/etc/apache2/httpd.conf" \
    && sed -i "s|#LoadModule include|LoadModule include|g" "/etc/apache2/httpd.conf" \
    && sed -i "s|#LoadModule log|LoadModule log|g" "/etc/apache2/httpd.conf"
