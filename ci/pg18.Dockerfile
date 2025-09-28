FROM debian:trixie

ENV	DEBIAN_FRONTEND=noninteractive
ENV	LANG=C.UTF-8
ENV	PGVER=18
ENV	PGCONFIG=/etc/postgresql/$PGVER/main/postgresql.conf
RUN	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get -y --no-install-recommends install curl gnupg ca-certificates

RUN	curl https://deb.yeti-switch.org/debian/yeti.gpg -o /etc/apt/trusted.gpg.d/yeti-key.asc && \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc -o /etc/apt/trusted.gpg.d/pgdg-key.asc && \
	echo "deb https://deb.yeti-switch.org/debian/1.14 trixie main" >> /etc/apt/sources.list && \
	echo "deb https://apt.postgresql.org/pub/repos/apt/ trixie-pgdg main" >> /etc/apt/sources.list

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
    echo "shared_preload_libraries = 'yeti_pg_ext'" >> $PGCONFIG && \
    cat "$PGCONFIG" && \
    echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/$PGVER/main/pg_hba.conf && \
	echo "host all all ::/0 trust" >> /etc/postgresql/$PGVER/main/pg_hba.conf

EXPOSE 5432
USER postgres:postgres
ENTRYPOINT ["/usr/lib/postgresql/18/bin/postgres", \
	"-D", "/var/lib/postgresql/18/main", \
	"-c", "config_file=/etc/postgresql/18/main/postgresql.conf"]
