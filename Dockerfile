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

RUN echo "LDAPTrustedMode SSL" >> /etc/apache2/apache2.conf && \
    echo "LDAPVerifyServerCert SSL" >> /etc/apache2/apache2.conf

ENV HOME /data
ENV LANG ru_RU.UTF-8
ENV APACHE_RUN_DIR /data/cherry
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /data/log
ENV APACHE_PID_FILE /run/apache2/apache2.pid

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME /data
WORKDIR /data/cherry

CMD [ "apache2", "-k", "start" ]
