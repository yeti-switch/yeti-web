FROM debian:stretch


RUN apt-get update && apt-get -y dist-upgrade && apt-get -y --no-install-recommends install wget gnupg
RUN wget http://pkg.yeti-switch.org/key.gpg -O - | apt-key add -
RUN echo "deb http://pkg.yeti-switch.org/debian/jessie unstable main ext" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y --no-install-recommends install build-essential devscripts \
    ca-certificates apt-transport-https debhelper fakeroot lintian python-jinja2 \
    ruby2.3 ruby2.3-dev zlib1g-dev libpq-dev python-yaml postgresql-client \
    git-changelog python-setuptools lsb-release curl

ADD . /build/yeti-web/
RUN sed -i '/host/s/127\.0\.0\.1/db/' /build/yeti-web/config/database.build.yml

WORKDIR /build/yeti-web/
CMD make package

