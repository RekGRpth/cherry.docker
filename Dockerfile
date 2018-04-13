FROM alpine

MAINTAINER RekGRpth

RUN apk add --no-cache \
        alpine-sdk \
        apache2 \
        apache2-ldap \
        apache2-ssl \
        perl \
        perl-cgi \
        perl-cgi-session \
        perl-dbd-pg \
        perl-dbi \
#        perl-module-build \
        perl-utils \
        perl-yaml-syck \
        shadow \
        su-exec \
        tzdata \
    && cpan -i CGI/Deurl.pm \
    && apk del \
        alpine-sdk \
#        perl-module-build \
        perl-utils

ENV HOME=/data \
    LANG=ru_RU.UTF-8 \
    TZ=Asia/Yekaterinburg \
    USER=apache \
    GROUP=apache

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh && usermod --home "${HOME}" "${USER}" && mkdir -p /run/apache2
ENTRYPOINT ["/entrypoint.sh"]

VOLUME  ${HOME}
WORKDIR ${HOME}/app

CMD [ "httpd", "-D", "FOREGROUND" ]
