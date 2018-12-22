FROM alpine:3.8

RUN apk add --no-cache python alpine-sdk libressl libressl-dev libcap libcap-dev geoip geoip-dev \
    && wget https://www.cpan.org/src/5.0/perl-5.28.1.tar.gz \
    && tar -xzf perl-5.28.1.tar.gz \
    && cd perl-5.28.1 \
    && ./Configure -des \
    && make \
    && make install \
    && python -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip install --upgrade pip setuptools \
    && pip install ply \
    && rm -r /root/.cache \
    && cd / && git clone https://github.com/isc-projects/bind9.git \
    && cd /bind9 && ./configure --enable-fixed-rrset --with-geoip && make && make install \
    && apk del alpine-sdk libressl-dev libcap-dev perl-dev && rm -rf /var/cache/apk/* \
    && apk add --update gcc \
    && rm -rf /bind9 /perl-5.28.1* \
    && mkdir "/var/bind"

VOLUME ["/etc/bind", "/var/log/named"]
EXPOSE 53/tcp 53/udp
WORKDIR /etc/bind
ENTRYPOINT ["/usr/local/sbin/named",  "-c", "/etc/bind/named.conf", "-f"]