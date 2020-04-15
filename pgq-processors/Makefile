SHELL := /bin/sh

gems := $(CURDIR)/vendor/bundler
bundle_bin := $(gems)/bin/bundle
bundler_gems := $(CURDIR)/vendor/bundle
export GEM_PATH := $(gems):$(bundler_gems)

define info
	@printf '\n\e[33m> msg \e[39m\n\n'
endef

###### Rules ######
.PHONY: all
all: gems


.PHONY: bundler
bundler:
	$(info:msg=Install bundler)
	gem install --no-document --install-dir $(gems) bundler -v 2.1.4


.PHONY: gems
gems: bundler
	$(info:msg=Install/Update gems)
	$(bundle_bin) config set deployment 'true'
	$(bundle_bin) install --jobs=4 --binstubs

.PHONY: test
test: gems
	RAILS_ENV=test PGQ_PROCESSORS_TEST=true $(bundle_bin) exec rspec


.PHONY: clean
clean:
	@$(info:msg=PGQ. removing bundler and gems)
	rm -rf $(gems)
	rm -rf $(bundler_gems)
