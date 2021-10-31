FROM debian:bullseye

ENV	DEBIAN_FRONTEND=noninteractive \
	LANG=C.UTF-8 \
        RAILS_ENV=production \
        RACK_ENV=production \
        RAKE_ENV=production \
        BUNDLE_GEMFILE=/opt/yeti-web/Gemfile \
        GEM_PATH=/opt/yeti-web/vendor/bundler 

RUN	apt update && \
	apt -y dist-upgrade && \
	apt -y --no-install-recommends install \
		curl \
		gnupg \
		ca-certificates \
		sudo && \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc	| apt-key add - && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main"	>> /etc/apt/sources.list && \
	apt update && \
	apt install -f -y --no-install-recommends procps cron

COPY	*.deb /
RUN	ls -la /

RUN	dpkg -i /*.deb || apt install -f -y --no-install-recommends

EXPOSE 3000/tcp

ENTRYPOINT ["/usr/bin/ruby", \
	"/opt/yeti-web/vendor/bundler/bin/bundle", "exec", "puma", \ 
	"-C", "/opt/yeti-web/config/puma_production.rb", \
        "--daemon", \ 
        "--pidfile", "/run/yeti/yeti-web-puma.pid", \
        "/opt/yeti-web/config.ru" ]
