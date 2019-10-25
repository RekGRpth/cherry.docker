FROM rekgrpth/gost
COPY cgi_perl.c /tmp/
ENV GROUP=cherry \
    USER=cherry
VOLUME "${HOME}"
RUN set -ex \
    && addgroup -S "${GROUP}" \
    && adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}" \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        make \
        musl-dev \
        perl-dev \
        perl-utils \
    && perl -MExtUtils::Embed -e xsinit -- -o /tmp/perlxsi.c \
    && gcc -c /tmp/perlxsi.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o /tmp/perlxsi.o \
    && gcc -c /tmp/cgi_perl.c -fPIC $(perl -MExtUtils::Embed -e ccopts) -o /tmp/cgi_perl.o \
    && gcc -shared -o /usr/local/lib/cgi_perl.so -fPIC /tmp/perlxsi.o /tmp/cgi_perl.o $(perl -MExtUtils::Embed -e ldopts) \
    && cpan -i CGI/Deurl.pm \
    && apk add --no-cache --virtual .cherry-rundeps \
        coreutils \
        perl \
        perl-cgi \
        perl-cgi-session \
        perl-dbd-pg \
        perl-dbi \
        perl-yaml-syck \
        uwsgi-cgi \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && (strip /usr/local/bin/* /usr/local/lib/*.so || true) \
    && apk del --no-cache .build-deps \
    && rm -rf /tmp/*