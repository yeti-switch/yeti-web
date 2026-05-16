#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=""
OS_NAME=""
BREW_BIN="${BREW_BIN:-brew}"
SUDO_BIN="${SUDO_BIN:-sudo}"
RUBY_VERSION_FILE="${RUBY_VERSION_FILE:-.ruby-version}"
PG_PORT="${PG_PORT:-5416}"
PG_MAJOR="${PG_MAJOR:-16}"
PROJECT_RUBY_VERSION=""

log() {
  printf '[yeti-bootstrap] %s\n' "$*"
}

fail() {
  printf '[yeti-bootstrap] ERROR: %s\n' "$*" >&2
  exit 1
}

run() {
  log "+ $*"
  "$@"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

detect_os() {
  case "${YETI_OS_OVERRIDE:-$(uname -s)}" in
    Darwin) OS_NAME="darwin" ;;
    Linux) OS_NAME="linux" ;;
    *) fail "unsupported OS: $(uname -s)" ;;
  esac
}

find_repo_root() {
  if [[ -n "${YETI_WEB_ROOT:-}" ]]; then
    [[ -d "$YETI_WEB_ROOT" ]] || fail "YETI_WEB_ROOT does not exist: $YETI_WEB_ROOT"
    ROOT_DIR="$(cd "$YETI_WEB_ROOT" && pwd)"
    return
  fi

  local start_dir="${1:-$PWD}"
  local dir="$start_dir"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/Gemfile" && -d "$dir/config" && -f "$dir/config/database.yml.development" ]]; then
      ROOT_DIR="$(cd "$dir" && pwd)"
      return
    fi
    dir="$(dirname "$dir")"
  done

  fail "could not find yeti-web root from $start_dir"
}

cd_repo_root() {
  cd "$ROOT_DIR"
}

read_ruby_version() {
  [[ -f "$RUBY_VERSION_FILE" ]] || fail "missing $RUBY_VERSION_FILE"
  PROJECT_RUBY_VERSION="$(tr -d '[:space:]' < "$RUBY_VERSION_FILE")"
  [[ -n "$PROJECT_RUBY_VERSION" ]] || fail "empty Ruby version in $RUBY_VERSION_FILE"
}

install_rbenv() {
  if command_exists rbenv; then
    log "rbenv already installed"
    return
  fi

  case "$OS_NAME" in
    darwin)
      run "$BREW_BIN" install rbenv ruby-build
      ;;
    linux)
      run "$SUDO_BIN" apt-get update
      run "$SUDO_BIN" apt-get install -y rbenv ruby-build
      ;;
  esac
}

configure_rbenv_shell() {
  export RBENV_ROOT="${RBENV_ROOT:-$HOME/.rbenv}"
  export PATH="$RBENV_ROOT/bin:$PATH"
  if command_exists rbenv; then
    eval "$(rbenv init - zsh)"
  fi
}

install_ruby() {
  if rbenv versions --bare | grep -qx "$PROJECT_RUBY_VERSION"; then
    log "Ruby $PROJECT_RUBY_VERSION already installed"
  else
    run rbenv install -s "$PROJECT_RUBY_VERSION"
  fi
  run rbenv local "$PROJECT_RUBY_VERSION"
}

install_postgres_and_lua() {
  case "$OS_NAME" in
    darwin)
      run "$BREW_BIN" install "postgresql@${PG_MAJOR}" "lua@5.4"
      run "$BREW_BIN" link --force "postgresql@${PG_MAJOR}"
      run "$BREW_BIN" link --force "lua@5.4"
      ;;
    linux)
      run "$SUDO_BIN" apt-get update
      run "$SUDO_BIN" apt-get install -y "postgresql-${PG_MAJOR}" postgresql-contrib "lua5.4"
      ;;
  esac
}

install_pg_extensions() {
  case "$OS_NAME" in
    linux)
      install_pg_extension_from_source /tmp/prefix
      install_pg_extension_from_source /tmp/pgq
      install_pg_extension_from_source /tmp/pgq-ext
      install_pg_extension_from_source /tmp/pllua
      install_pg_extension_from_source /tmp/yeti-pg-ext
      ;;
    darwin)
      log "macOS does not have repo-managed apt packages for prefix/pgq/pgq-ext/pllua"
      log "If these extensions are required locally, install them from source or a matching tap."
      ;;
  esac
}

install_pg_extension_from_source() {
  local source_dir="$1"
  local make_args=()

  if [[ "$(basename "$source_dir")" == "pllua" ]]; then
    make_args=(
      LUA_INCDIR="${LUA_INCDIR:-/usr/include/lua5.4}"
      LUALIB="${LUALIB:--llua5.4}"
      LUAC="${LUAC:-/usr/bin/luac5.4}"
      LUA="${LUA:-/usr/bin/lua5.4}"
    )
  fi

  if [[ ! -d "$source_dir" ]]; then
    log "Skipping source build for $(basename "$source_dir") because $source_dir is absent"
    return 0
  fi

  run make -C "$source_dir" "${make_args[@]}"
  run "$SUDO_BIN" make -C "$source_dir" "${make_args[@]}" install
}

setup_postgres_cluster_linux() {
  [[ "$OS_NAME" == "linux" ]] || return 0

  create_postgres_cluster_linux m "$PG_PORT"
}

setup_postgres_test_cluster_linux() {
  [[ "$OS_NAME" == "linux" ]] || return 0

  create_postgres_cluster_linux test 5400
}

create_postgres_cluster_linux() {
  local cluster_name="$1"
  local cluster_port="$2"

  if command_exists pg_lsclusters && pg_lsclusters | awk 'NR>1 {print $1, $2}' | grep -q "^${PG_MAJOR} ${cluster_name}$"; then
    log "PostgreSQL cluster ${PG_MAJOR}/${cluster_name} already exists"
  else
    run "$SUDO_BIN" pg_createcluster "$PG_MAJOR" "$cluster_name" --port="$cluster_port" -- --auth=trust
  fi

  local hba="/etc/postgresql/${PG_MAJOR}/${cluster_name}/pg_hba.conf"
  if [[ -f "$hba" ]]; then
    run "$SUDO_BIN" perl -0pi -e 's/^(host\s+all\s+all\s+0\.0\.0\.0\/0\s+).*/$1trust/m; s/^(host\s+all\s+all\s+::\/0\s+).*/$1trust/m' "$hba"
    if ! grep -q '^host all all 0.0.0.0/0 trust$' "$hba"; then
      printf '%s\n' "host all all 0.0.0.0/0 trust" | "$SUDO_BIN" tee -a "$hba" >/dev/null
    fi
    if ! grep -q '^host all all ::/0 trust$' "$hba"; then
      printf '%s\n' "host all all ::/0 trust" | "$SUDO_BIN" tee -a "$hba" >/dev/null
    fi
  fi

  start_postgres_cluster_linux "$cluster_name" "$cluster_port"
}

start_postgres_cluster_linux() {
  local cluster_name="$1"
  local cluster_port="$2"

  run "$SUDO_BIN" pg_ctlcluster "$PG_MAJOR" "$cluster_name" start
  wait_for_postgres "$cluster_port"
}

wait_for_postgres() {
  local cluster_port="$1"
  local attempts=30

  until pg_isready -h 127.0.0.1 -p "$cluster_port" >/dev/null 2>&1; do
    attempts=$((attempts - 1))
    if [[ "$attempts" -le 0 ]]; then
      fail "PostgreSQL did not become ready on 127.0.0.1:${cluster_port}"
    fi
    sleep 1
  done
}

copy_project_configs() {
  cp -f config/database.yml.development config/database.yml
  cp -f config/yeti_web.yml.development config/yeti_web.yml
  cp -f config/policy_roles.yml.distr config/policy_roles.yml
  cp -f config/secrets.yml.distr config/secrets.yml
}

update_yeti_web_config() {
  sed -i.bak -E \
    -e 's/^([[:space:]]*when_no_config:[[:space:]]*)disallow.*$/\1allow/' \
    -e 's/^([[:space:]]*when_no_policy_class:[[:space:]]*)raise.*$/\1allow/' \
    config/yeti_web.yml
  rm -f config/yeti_web.yml.bak
}

update_database_port() {
  sed -i.bak -E 's/^([[:space:]]*port:[[:space:]]*)5432$/\15416/' config/database.yml
  rm -f config/database.yml.bak
}

bundle_install_gems() {
  run bundle install
}

prepare_test_database() {
  run env RAILS_ENV=test bundle exec rake db:create db:schema:load db:migrate db:seed
  case "$OS_NAME" in
    darwin)
      run env RAILS_ENV=test bundle exec rake 'custom_seeds[network_prefixes]'
      ;;
    linux)
      run env RAILS_ENV=test bundle exec rake custom_seeds[network_prefixes]
      ;;
  esac
}

run_specs() {
  run bundle exec rspec spec/models/billing/provisioning -f d
}

main() {
  local start_dir="${1:-$PWD}"
  find_repo_root "$start_dir"
  cd_repo_root
  detect_os
  read_ruby_version
  configure_rbenv_shell
  install_rbenv
  configure_rbenv_shell
  install_ruby
  install_postgres_and_lua
  install_pg_extensions
  setup_postgres_cluster_linux
  bundle_install_gems
  setup_postgres_test_cluster_linux
  copy_project_configs
  update_yeti_web_config
  update_database_port
  prepare_test_database
  run_specs
  log "Development environment bootstrap completed"
}

main "$@"
