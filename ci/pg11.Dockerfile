FROM debian:stretch

ENV	DEBIAN_FRONTEND=noninteractive
ENV	LANG=C.UTF-8
ENV	PGVER=11
ENV	PGCONFIG=/etc/postgresql/$PGVER/main/postgresql.conf
RUN	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get -y --no-install-recommends install \
		curl \
		gnupg \
		ca-certificates

RUN	curl https://pkg.yeti-switch.org/key.gpg | apt-key add - && \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc	| apt-key add - && \
	echo "deb http://pkg.yeti-switch.org/debian/stretch unstable main" >> /etc/apt/sources.list && \
	echo "deb http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list

RUN 	apt-get update && \
	apt-get -y --no-install-recommends install \
		postgresql-$PGVER \
		postgresql-contrib-$PGVER \
		postgresql-$PGVER-prefix \
		postgresql-$PGVER-pgq3 \
		postgresql-$PGVER-pgq-ext \
		postgresql-$PGVER-pllua \
		postgresql-$PGVER-yeti

RUN	sed -Ei "/^#?listen_addresses +=/s/.*/listen_addresses = '*'/"		"$PGCONFIG" && \
	sed -Ei "/^#?log_connections +=/s/.*/log_connections = on/"		"$PGCONFIG" && \
	sed -Ei "/^#?log_disconnections +=/s/.*/log_disconnections = on/"	"$PGCONFIG" && \
	sed -Ei "/^#?fsync +=/s/.*/fsync = off/"				"$PGCONFIG" && \
	sed -Ei "/^#?synchronous_commit +=/s/.*/synchronous_commit = off/"	"$PGCONFIG" && \
	sed -Ei "/^#?checkpoint_timeout +=/s/.*/checkpoint_timeout = 50min/"	"$PGCONFIG" && \
	sed -Ei "/^#?ssl +=/s/.*/ssl = off/"					"$PGCONFIG" && \
	sed -Ei "/^#?autovacuum +=/s/.*/autovacuum = off/"			"$PGCONFIG" && \
	cat "$PGCONFIG" && \
	echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/$PGVER/main/pg_hba.conf

EXPOSE 5432
USER postgres:postgres
ENTRYPOINT ["/usr/lib/postgresql/11/bin/postgres", \
	"-D", "/var/lib/postgresql/11/main", \
	"-c", "config_file=/etc/postgresql/11/main/postgresql.conf"]
