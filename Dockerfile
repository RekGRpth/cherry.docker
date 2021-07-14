FROM rekgrpth/gost
ENV GROUP=cherry \
    USER=cherry
VOLUME "${HOME}"
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk add --no-cache --virtual .build-deps \
        ca-certificates \
        gcc \
        git \
        gnupg \
        make \
        musl-dev \
        perl-dev \
        perl-utils \
        postgresql-dev \
    ; \
    mkdir -p /usr/src; \
    cd /usr/src; \
    git clone https://bitbucket.org/RekGRpth/cherry.git; \
    cd /usr/src/cherry; \
    perl -MExtUtils::Embed -e xsinit -- -o perlxsi.c; \
    gcc -c perlxsi.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o perlxsi.o; \
    gcc -c cgi_perl.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o cgi_perl.o; \
    gcc -shared -o /usr/local/lib/cgi_perl.so -fPIC perlxsi.o cgi_perl.o $(perl -MExtUtils::Embed -e ldopts); \
    cpan -Ti CGI CGI::Deurl CGI::FastTemplate CGI::Session DBD::Pg DBI YAML YAML::Syck; \
    apk add --no-cache --virtual .cherry-rundeps \
        coreutils \
        uwsgi-cgi \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    apk del --no-cache .build-deps; \
    rm -rf /usr/src /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find / -name "*.a" -delete; \
    find / -name "*.la" -delete; \
    find /usr/bin /usr/lib /usr/local/bin /usr/local/lib -type f -exec strip '{}' \;; \
    echo done
