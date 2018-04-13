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
        perl-module-build \
        perl-utils \
        perl-yaml-syck \
        shadow \
        su-exec \
        tzdata \
    && cpan -i CGI/Deurl.pm \
    && apk del \
        alpine-sdk \
        perl-module-build \
        perl-utils

#RUN apt-get update --yes --quiet \
#    && apt-get full-upgrade --yes --quiet \
#    && apt-get install --yes --quiet --no-install-recommends \
#        apache2 \
#        apache2-suexec-pristine \
#        fakeroot \
#        locales \
#    && ln --force --symbolic /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime \
#    && echo "Asia/Yekaterinburg" > /etc/timezone \
#    && apt-get remove --quiet --auto-remove --yes \
#    && apt-get clean --quiet --yes \
#    && rm --recursive --force /var/lib/apt/lists/* \
#    && echo "\"\\e[A\": history-search-backward" >> /etc/inputrc \
#    && echo "\"\\e[B\": history-search-forward" >> /etc/inputrc

ENV HOME=/data \
    LANG=ru_RU.UTF-8 \
    TZ=Asia/Yekaterinburg \
    USER=apache \
    GROUP=apache

#RUN echo "IncludeOptional ${HOME}/apache2/*.conf" >> /etc/apache2/httpd.conf \
#    && ln -fs ../mods-available/authnz_ldap.load /etc/apache2/mods-enabled/authnz_ldap.load \
#    && ln -fs ../mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load \
#    && ln -fs ../mods-available/cgid.load /etc/apache2/mods-enabled/cgid.load \
#    && ln -fs ../mods-available/cgid.conf /etc/apache2/mods-enabled/cgid.conf \
#    && ln -fs ../mods-available/ldap.conf /etc/apache2/mods-enabled/ldap.conf \
#    && ln -fs ../mods-available/ldap.load /etc/apache2/mods-enabled/ldap.load \
#    && ln -fs ../mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load \
#    && ln -fs ../mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load \
#    && ln -fs ../mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf \
#    && ln -fs ../mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load \
#    && ln -fs ../mods-available/suexec.load /etc/apache2/mods-enabled/suexec.load \
#    && rm -f /etc/apache2/sites-enabled/*.conf

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh && usermod --home "${HOME}" "${USER}" && mkdir -p /run/apache2
ENTRYPOINT ["/entrypoint.sh"]

VOLUME  ${HOME}
WORKDIR ${HOME}/app

CMD [ "httpd", "-D", "FOREGROUND" ]
