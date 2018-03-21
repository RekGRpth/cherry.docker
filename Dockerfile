FROM debian:buster-slim

MAINTAINER RekGRpth

RUN apt-get update --yes --quiet && \
    apt-get full-upgrade --yes --quiet && \
    apt-get install --yes --quiet --no-install-recommends \
        apache2 \
        apache2-suexec-pristine \
        fakeroot \
        locales \
        && \
    ln --force --symbolic /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime && \
    echo "Asia/Yekaterinburg" > /etc/timezone && \
    apt-get remove --quiet --auto-remove --yes && \
    apt-get clean --quiet --yes && \
    rm --recursive --force /var/lib/apt/lists/* && \
    echo "\"\\e[A\": history-search-backward" >> /etc/inputrc && \
    echo "\"\\e[B\": history-search-forward" >> /etc/inputrc

RUN echo "IncludeOptional /data/apache2/*.conf" >> /etc/apache2/apache2.conf && \
    ln --force --symbolic ../mods-available/authnz_ldap.load /etc/apache2/mods-enabled/authnz_ldap.load && \
    ln --force --symbolic ../mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load && \
    ln --force --symbolic ../mods-available/cgid.load /etc/apache2/mods-enabled/cgid.load && \
    ln --force --symbolic ../mods-available/cgid.conf /etc/apache2/mods-enabled/cgid.conf && \
    ln --force --symbolic ../mods-available/ldap.conf /etc/apache2/mods-enabled/ldap.conf && \
    ln --force --symbolic ../mods-available/ldap.load /etc/apache2/mods-enabled/ldap.load && \
    ln --force --symbolic ../mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
    ln --force --symbolic ../mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load && \
    ln --force --symbolic ../mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf && \
    ln --force --symbolic ../mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load && \
    ln --force --symbolic ../mods-available/suexec.load /etc/apache2/mods-enabled/suexec.load && \
    rm --force /etc/apache2/sites-enabled/*.conf

ENV HOME /data \
    LANG ru_RU.UTF-8

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME /data
WORKDIR /data/cherry

CMD [ "apache2ctl", "-DFOREGROUND" ]
