FROM debian:buster

ENV	DEBIAN_FRONTEND=noninteractive \
	LANG=C.UTF-8

RUN	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get -y --no-install-recommends install \
		curl \
		gnupg \
		ca-certificates \
		sudo

RUN	echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	adduser --disabled-password --gecos "" build && \
	curl http://pkg.yeti-switch.org/key.gpg			| apt-key add - && \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc	| apt-key add - && \
	echo "deb http://pkg.yeti-switch.org/debian/buster unstable main"	>> /etc/apt/sources.list && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main"	>> /etc/apt/sources.list 

RUN 	apt-get update && \
	apt-get -y --no-install-recommends install \
		build-essential \
		devscripts \
		ca-certificates \
		debhelper \
		fakeroot \
		lintian \
		python-jinja2 \
		ruby2.6 \
		ruby2.6-dev \
		zlib1g-dev \
		libpq-dev \
		python-yaml \
		postgresql-client-12 \
		git-changelog \
		python-setuptools \
		lsb-release \
		&& \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sSO https://dl.google.com/dl/linux/direct/google-chrome-stable_current_amd64.deb && \
	{ dpkg -i google-chrome-stable_current_amd64.deb || /bin/true; } && \
	apt-get update && apt-get -y --no-install-recommends --fix-broken install && \
	rm -v google-chrome-stable_current_amd64.deb && \
	google-chrome-stable --version && \
	apt-get clean && rm -rf /var/lib/apt/lists/*
