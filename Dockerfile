FROM rekgrpth/gost
ENV GROUP=cherry \
    USER=cherry
VOLUME "${HOME}"
RUN set -ex \
    && addgroup -S "${GROUP}" \
    && adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}" \
    && apk add --no-cache --virtual .build-deps \
        make \
        perl-utils \
    && cpan -i CGI/Deurl.pm \
    && apk del \
        perl-utils \
    && apk add --no-cache --virtual .cherry-rundeps \
        coreutils \
        perl \
        perl-cgi \
        perl-cgi-session \
        perl-dbd-pg \
        perl-dbi \
        perl-yaml-syck \
        uwsgi-cgi \
    && apk del --no-cache .build-deps
