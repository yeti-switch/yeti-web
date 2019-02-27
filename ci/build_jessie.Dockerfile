FROM debian:jessie


RUN apt-get update && apt-get -y dist-upgrade && apt-get -y --no-install-recommends install wget
RUN wget http://pkg.yeti-switch.org/key.gpg -O - | apt-key add -
RUN echo "deb http://pkg.yeti-switch.org/debian/jessie 1.7 main" >> /etc/apt/sources.list
RUN echo "deb http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list
RUN echo "Package: *\nPin: release n=buster\nPin-Priority: 50\n\nPackage: python-git python-gitdb python-smmap python-tzlocal\nPin: release n=buster\nPin-Priority: 500\n\n" | tee /etc/apt/preferences

RUN apt-get update && apt-get -y --no-install-recommends install build-essential devscripts \
    ca-certificates apt-transport-https debhelper fakeroot lintian python-jinja2 \
    ruby2.3 ruby2.3-dev zlib1g-dev libpq-dev python-yaml postgresql-client \
    git-changelog python-setuptools lsb-release curl

ADD . /build/yeti-web/
RUN sed -i '/host/s/127\.0\.0\.1/db/' /build/yeti-web/config/database.build.yml

WORKDIR /build/yeti-web/
CMD make package

