FROM debian:buster

ENV	DEBIAN_FRONTEND=noninteractive \
	LANG=C.UTF-8

ADD http://pkg.yeti-switch.org/key.gpg /etc/apt/trusted.gpg.d/yeti-switch.asc
ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /etc/apt/trusted.gpg.d/postgres.asc

RUN	echo "deb http://pkg.yeti-switch.org/debian/buster unstable main" >> /etc/apt/sources.list && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >> /etc/apt/sources.list  && \
	chmod 644 /etc/apt/trusted.gpg.d/*.asc

COPY debian/control debian/control 

RUN	apt update && \
	apt -y --no-install-recommends build-dep . && \
	rm -r debian/

ADD https://dl.google.com/dl/linux/direct/google-chrome-stable_current_amd64.deb .

RUN	apt install -y ./google-chrome-stable_current_amd64.deb && \
	google-chrome-stable --version && \
	rm -v google-chrome-stable_current_amd64.deb && \
	apt clean && rm -rf /var/lib/apt/lists/*
	
#WORKDIR /build/yeti-web 
#COPY . .
