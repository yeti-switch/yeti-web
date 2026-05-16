#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

make_mock_bin() {
  local mock_dir="$1"
  mkdir -p "$mock_dir"

  cat > "$mock_dir/sudo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "sudo $*" >> "$MOCK_LOG"
exec "$@"
EOF

  cat > "$mock_dir/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "brew $*" >> "$MOCK_LOG"
exit 0
EOF

  cat > "$mock_dir/apt-get" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "apt-get $*" >> "$MOCK_LOG"
exit 0
EOF

  cat > "$mock_dir/rbenv" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "rbenv $*" >> "$MOCK_LOG"
case "${1:-}" in
  init)
    printf 'export RBENV_MOCK_INITIALIZED=1\n'
    ;;
  versions)
    exit 0
    ;;
  install|local)
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
EOF

  cat > "$mock_dir/bundle" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "bundle $*" >> "$MOCK_LOG"
exit 0
EOF

  cat > "$mock_dir/pg_lsclusters" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "pg_lsclusters $*" >> "$MOCK_LOG"
printf 'Ver Cluster Port Status Owner Data directory Log file\n'
exit 0
EOF

  cat > "$mock_dir/pg_createcluster" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "pg_createcluster $*" >> "$MOCK_LOG"
exit 0
EOF

  cat > "$mock_dir/pg_ctlcluster" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "pg_ctlcluster $*" >> "$MOCK_LOG"
exit 0
EOF

  cat > "$mock_dir/pg_isready" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "pg_isready $*" >> "$MOCK_LOG"
exit 0
EOF

  cat > "$mock_dir/make" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "make $*" >> "$MOCK_LOG"
exit 0
EOF

  chmod +x "$mock_dir"/*
}

prepare_repo_copy() {
  local repo_copy="$1"
  cp -R "$REPO_ROOT/." "$repo_copy"
}

assert_contains() {
  local file="$1"
  local needle="$2"
  grep -Fq "$needle" "$file"
}

run_case() {
  local os_name="$1"
  local workdir
  workdir="$(mktemp -d)"
  local mock_bin="$workdir/mock-bin"
  local log="$workdir/mock.log"
  local repo="$workdir/repo"
  mkdir -p "$repo"
  prepare_repo_copy "$repo"
  make_mock_bin "$mock_bin"
  : > "$log"

  (
    cd "$repo"
    PATH="$mock_bin:$PATH" \
    MOCK_LOG="$log" \
    YETI_WEB_ROOT="$repo" \
    YETI_OS_OVERRIDE="$os_name" \
    RUBY_VERSION_FILE=".ruby-version" \
    PG_PORT="5416" \
    PG_MAJOR="16" \
    SUDO_BIN="sudo" \
    BREW_BIN="brew" \
    "$repo/bin/bootstrap-dev-env.sh" "$repo"
  )

  assert_contains "$repo/config/yeti_web.yml" "when_no_config: allow"
  assert_contains "$repo/config/yeti_web.yml" "when_no_policy_class: allow"
  grep -Fq 'port: 5416' "$repo/config/database.yml"

  if [[ "$os_name" == "Linux" ]]; then
    assert_contains "$log" "pg_createcluster 16 m --port=5416 -- --auth=trust"
    assert_contains "$log" "pg_ctlcluster 16 m start"
    assert_contains "$log" "pg_createcluster 16 test --port=5400 -- --auth=trust"
    assert_contains "$log" "pg_ctlcluster 16 test start"
    assert_contains "$log" "bundle exec rake custom_seeds[network_prefixes]"
  else
    assert_contains "$log" "brew install postgresql@16 lua@5.4"
    assert_contains "$log" "bundle exec rake custom_seeds[network_prefixes]"
  fi
}

main() {
  run_case Linux
  run_case Darwin
  printf 'dev-env bootstrap tests passed\n'
}

main "$@"
