FROM ghcr.io/rekgrpth/gost.docker
ADD cgi_perl.c "${HOME}/src/"
ENV GROUP=cherry \
    USER=cherry
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build-deps \
        gcc \
        gnupg \
        libpq-dev \
        make \
        musl-dev \
        perl-dev \
        perl-utils \
    ; \
    cd "${HOME}/src"; \
    perl -MExtUtils::Embed -e xsinit -- -o perlxsi.c; \
    gcc -c perlxsi.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o perlxsi.o; \
    gcc -c cgi_perl.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o cgi_perl.o; \
    gcc -shared -o /usr/local/lib/cgi_perl.so -fPIC perlxsi.o cgi_perl.o $(perl -MExtUtils::Embed -e ldopts); \
    cd "${HOME}"; \
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
    apk add --no-cache --virtual .cherry-rundeps \
        coreutils \
        uwsgi-cgi \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    echo done
