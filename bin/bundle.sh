#!/bin/bash

export GEM_HOME=vendor/bundler
export RBENV_ROOT="$(realpath ./vendor/rbenv)"
export PATH="$RBENV_ROOT/shims:$GEM_HOME/bin:$PATH"
./vendor/bundler/bin/bundler $@

