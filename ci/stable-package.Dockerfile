# syntax=docker/dockerfile:1

# Use the official Debian image
FROM debian:bookworm AS builder

# Install dependencies
RUN apt-get update -q && apt-get dist-upgrade -yq \
    && apt-get install --no-install-recommends -yq \
      build-essential \
      ca-certificates \
      curl \
      git \
      libc-dev \
      libpq-dev \
      libssl-dev \
      pkg-config

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C target-cpu=native"

# Cloning and building pg2parquet
RUN git clone https://github.com/exyi/pg2parquet.git /src
WORKDIR /src/cli
RUN cargo build --release

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

# Install dependencies
RUN apt-get update -q && apt-get dist-upgrade -yq \
    && apt-get install --no-install-recommends -yq \
      ca-certificates \
      cron \
      curl \
      gnupg \
      libpq5 \
      libpq-dev \
      procps \
      python3-pip \
      sudo \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/apt_postgresql_org_pub_repos_apt.list \
    && curl -sSl https://www.postgresql.org/media/keys/ACCC4CF8.asc -o /etc/apt/trusted.gpg.d/pgdg-key.asc \
    # Install s3cmd package for uploading to s3 bucket
    && pip install --quiet --no-cache-dir --break-system-packages s3cmd \
      && apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy binary file from the builder stage
COPY --from=builder /src/cli/target/release/pg2parquet /usr/local/bin/pg2parquet

# Install Ruby debian package
COPY *.deb /
RUN dpkg -i /*.deb || apt-get install -f --no-install-recommends -yq && rm -f /*.deb

EXPOSE 3000/tcp

ENTRYPOINT ["/usr/bin/ruby", \
  "/opt/yeti-web/vendor/bundler/bin/bundle", "exec", "puma", \
  "-C", "/opt/yeti-web/config/puma_production.rb", \
  "--pidfile", "/run/yeti/yeti-web-puma.pid", \
  "/opt/yeti-web/config.ru"]
