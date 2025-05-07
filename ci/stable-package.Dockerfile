# syntax=docker/dockerfile:1

# Use the official Debian image
FROM debian:bookworm AS builder

# Install dependencies
RUN apt-get update -q && apt-get dist-upgrade -yq \
    && apt-get install --no-install-recommends -yq \
      apt-utils \
      build-essential \
      ca-certificates \
      curl \
      git \
      libc-dev \
      libpq-dev \
      libssl-dev \
      pkg-config \
      python3 \
      python3-venv \
      python3-pip

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C target-cpu=native"

# Cloning and building pg2parquet
RUN git clone https://github.com/exyi/pg2parquet.git /src
WORKDIR /src/cli
RUN cargo build --release

# Creating virtualenv and install s3cmd
RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install s3cmd

# Use the official Debian minimal image
FROM debian:bookworm-slim

ENV \
  DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8 \
  RAILS_ENV=production \
  RACK_ENV=production \
  RAKE_ENV=production \
  BUNDLE_GEMFILE=/opt/yeti-web/Gemfile \
  GEM_PATH=/opt/yeti-web/vendor/bundler

# Copy yeti-web debian package
WORKDIR /
COPY *.deb ./

# Install dependencies
RUN apt-get update -q && apt-get dist-upgrade -yq \
    && apt-get install --no-install-recommends -yq \
      apt-utils \
      ca-certificates \
      curl \
      gnupg \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/apt_postgresql_org_pub_repos_apt.list \
    && curl -sSl https://www.postgresql.org/media/keys/ACCC4CF8.asc -o /etc/apt/trusted.gpg.d/pgdg-key.asc \
    && apt-get update -q \
    && apt-get install --no-install-recommends -yq \
      cron \
      libpq5 \
      libpq-dev \
      procps \
      python3 \
      sudo \
    && apt-get install -yq /*.deb && rm -f /*.deb \
      && apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy binary file and virtualenv from the builder stage
COPY --from=builder /src/cli/target/release/pg2parquet /usr/local/bin/pg2parquet
COPY --from=builder /venv /venv

# Add virtualenv to PATH
ENV PATH="/venv/bin:$PATH"

EXPOSE 3000/tcp

ENTRYPOINT ["/usr/bin/ruby", \
  "/opt/yeti-web/vendor/bundler/bin/bundle", "exec", "puma", \
  "-C", "/opt/yeti-web/config/puma_production.rb", \
  "--pidfile", "/run/yeti/yeti-web-puma.pid", \
  "/opt/yeti-web/config.ru"]
