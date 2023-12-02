FROM alpine:latest
ADD bin /usr/local/bin
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV HOME=/home
MAINTAINER RekGRpth
WORKDIR "$HOME"
ADD cgi_perl.c "$HOME/src/"
ENV GROUP=cherry \
    USER=cherry
RUN set -eux; \
    ln -fs su-exec /sbin/gosu; \
    chmod +x /usr/local/bin/*.sh; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    addgroup -S "$GROUP"; \
    adduser -S -D -G "$GROUP" -H -h "$HOME" -s /sbin/nologin "$USER"; \
    apk add --no-cache --virtual .build \
        gcc \
        gnupg \
        libpq-dev \
        make \
        musl-dev \
        perl-dev \
        perl-utils \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    perl -MExtUtils::Embed -e xsinit -- -o perlxsi.c; \
    gcc -c perlxsi.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o perlxsi.o; \
    gcc -c cgi_perl.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o cgi_perl.o; \
    gcc -shared -o /usr/local/lib/cgi_perl.so -fPIC perlxsi.o cgi_perl.o $(perl -MExtUtils::Embed -e ldopts); \
    cd "$HOME"; \
    cpan -Ti \
        CGI \
        CGI::Deurl \
        CGI::FastTemplate \
        CGI::Session \
        DBD::Pg \
        DBI \
        Text::Iconv \
        utf8::all \
        YAML \
        YAML::Syck \
    ; \
    cd /; \
    apk add --no-cache --virtual .cherry \
        busybox-extras \
        busybox-suid \
        ca-certificates \
        coreutils \
        musl-locales \
        shadow \
        su-exec \
        tzdata \
        uwsgi-cgi \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | grep -v -e libcrypto | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    echo done
