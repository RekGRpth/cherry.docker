FROM rekgrpth/gost
ADD cgi_perl.c "${HOME}/src/"
ENV GROUP=cherry \
    USER=cherry
VOLUME "${HOME}"
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk add --no-cache --virtual .build-deps \
        gcc \
        gnupg \
        make \
        musl-dev \
        perl-dev \
        perl-utils \
        postgresql-dev \
    ; \
    cd "${HOME}/src"; \
    perl -MExtUtils::Embed -e xsinit -- -o perlxsi.c; \
    gcc -c perlxsi.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o perlxsi.o; \
    gcc -c cgi_perl.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o cgi_perl.o; \
    gcc -shared -o /usr/local/lib/cgi_perl.so -fPIC perlxsi.o cgi_perl.o $(perl -MExtUtils::Embed -e ldopts); \
    cd "${HOME}"; \
    cpan -Ti CGI CGI::Deurl CGI::FastTemplate CGI::Session DBD::Pg DBI YAML YAML::Syck; \
    apk add --no-cache --virtual .cherry-rundeps \
        coreutils \
        uwsgi-cgi \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    find / -type f -name "*.a" -delete; \
    find / -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    echo done
