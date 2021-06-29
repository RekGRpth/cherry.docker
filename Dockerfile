FROM rekgrpth/gost
COPY cgi_perl.c /tmp/
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
    perl -MExtUtils::Embed -e xsinit -- -o /tmp/perlxsi.c; \
    gcc -c /tmp/perlxsi.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o /tmp/perlxsi.o; \
    gcc -c /tmp/cgi_perl.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o /tmp/cgi_perl.o; \
    gcc -shared -o /usr/local/lib/cgi_perl.so -fPIC /tmp/perlxsi.o /tmp/cgi_perl.o $(perl -MExtUtils::Embed -e ldopts); \
    cpan -Ti CGI CGI::Deurl CGI::FastTemplate CGI::Session DBD::Pg DBI YAML YAML::Syck; \
    apk add --no-cache --virtual .cherry-rundeps \
        coreutils \
        uwsgi-cgi \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    (strip /usr/local/bin/* /usr/local/lib/*.so || true); \
    apk del --no-cache .build-deps; \
    rm -rf /tmp/* /usr/src /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    echo done
