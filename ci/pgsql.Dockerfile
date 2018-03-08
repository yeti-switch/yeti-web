FROM debian:jessie

# set default locale
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales wget && \
    sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" >> /etc/default/locale

ENV LANG en_US.UTF-8

RUN wget http://pkg.yeti-switch.org/key.gpg -O - | apt-key add - && \
    echo "deb http://pkg.yeti-switch.org/debian/jessie unstable main ext" >> /etc/apt/sources.list
RUN apt-get update && apt-get -y install --no-install-recommends postgresql-9.4 postgresql-contrib-9.4 postgresql-9.4-prefix postgresql-9.4-pgq3 postgresql-9.4-yeti

RUN echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/9.4/main/pg_hba.conf

RUN sed -i "/^#listen_addresses/s/.*/listen_addresses = '*'/" /etc/postgresql/9.4/main/postgresql.conf && \
    sed -i "/^#log_connections/s/.*/log_connections = on/" /etc/postgresql/9.4/main/postgresql.conf && \
    sed -i "/^#log_disconnections/s/.*/log_disconnections = on/" /etc/postgresql/9.4/main/postgresql.conf && \
    sed -i "/^#log_statement/s/.*/log_statement = 'all'/" /etc/postgresql/9.4/main/postgresql.conf && \
    sed -i "/^#fsync/s/.*/fsync = off/" /etc/postgresql/9.4/main/postgresql.conf && \
    sed -i "/^#synchronous_commit/s/.*/synchronous_commit = off/" /etc/postgresql/9.4/main/postgresql.conf && \
    sed -i "/^#checkpoint_segments/s/.*/checkpoint_segments = 10/" /etc/postgresql/9.4/main/postgresql.conf && \
    sed -i "/^#checkpoint_timeout/s/.*/checkpoint_timeout = 50min/" /etc/postgresql/9.4/main/postgresql.conf

EXPOSE 5432

CMD ["su", "-", "postgres", "-c", "/usr/lib/postgresql/9.4/bin/postgres -D /var/lib/postgresql/9.4/main -c config_file=/etc/postgresql/9.4/main/postgresql.conf"]

