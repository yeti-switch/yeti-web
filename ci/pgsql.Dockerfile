FROM debian:stretch

# set default locale
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales wget gnupg && \
    sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" >> /etc/default/locale

ENV LANG en_US.UTF-8

RUN wget http://pkg.yeti-switch.org/key.gpg -O - | apt-key add - && echo "deb http://pkg.yeti-switch.org/debian/stretch unstable main ext" >> /etc/apt/sources.list
RUN wget --no-check-certificate https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add - && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y install --no-install-recommends postgresql-11 postgresql-contrib-11 postgresql-11-prefix postgresql-11-pgq3 postgresql-11-pgq-ext postgresql-11-yeti

RUN echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/11/main/pg_hba.conf

RUN sed -i "/^#listen_addresses/s/.*/listen_addresses = '*'/" /etc/postgresql/11/main/postgresql.conf && \
    sed -i "/^#log_connections/s/.*/log_connections = on/" /etc/postgresql/11/main/postgresql.conf && \
    sed -i "/^#log_disconnections/s/.*/log_disconnections = on/" /etc/postgresql/11/main/postgresql.conf && \
    sed -i "/^#log_statement/s/.*/log_statement = 'all'/" /etc/postgresql/11/main/postgresql.conf && \
    sed -i "/^#fsync/s/.*/fsync = off/" /etc/postgresql/11/main/postgresql.conf && \
    sed -i "/^#synchronous_commit/s/.*/synchronous_commit = off/" /etc/postgresql/11/main/postgresql.conf && \
    sed -i "/^#checkpoint_timeout/s/.*/checkpoint_timeout = 50min/" /etc/postgresql/11/main/postgresql.conf

EXPOSE 5432

CMD ["su", "-", "postgres", "-c", "/usr/lib/postgresql/11/bin/postgres -D /var/lib/postgresql/11/main -c config_file=/etc/postgresql/11/main/postgresql.conf"]

