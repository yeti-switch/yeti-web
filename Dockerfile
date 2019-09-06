ARG DEBIAN=stretch
FROM switchyeti/yeti-web:${DEBIAN}-build
USER build
ADD --chown=build:build Gemfile Gemfile.lock Makefile vendor /build/yeti-web/
WORKDIR /build/yeti-web
RUN make gems-test
ADD --chown=build:build . /build/yeti-web/
