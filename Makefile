SHELL := /bin/sh

pkg_name := yeti-web
user := yeti-web
app_dir := /opt/$(user)
version_file := version.yml
app_files :=	bin \
		app \
		.bundle \
		config \
		config.ru \
		db \
		doc \
		Gemfile \
		Gemfile.lock \
		lib \
		public \
		Rakefile \
		vendor \
		pgq-processors \
		$(version_file)

exclude_files := config/database.yml \
		*.o \
		*.a

version = $(shell dpkg-parsechangelog --help | grep -q '\--show-field' \
	&& dpkg-parsechangelog --show-field version \
	|| dpkg-parsechangelog | grep Version | awk '{ print $$2; }')
commit = $(shell git rev-parse HEAD)

debian_host_release != lsb_release -sc
export DEBFULLNAME ?= YETI team
export DEBEMAIL ?= dev@yeti-switch.org
gems := $(CURDIR)/vendor/bundler
bundle_bin := $(gems)/bin/bundle
bundler_gems := $(CURDIR)/vendor/bundle
export GEM_PATH := $(gems):$(bundler_gems)

debuild_env :=	http_proxy \
		https_proxy \
		SSH_AUTH_SOCK \
		TRAVIS_* \
		CI_* \
		GITLAB_* \
		YETI_DB_HOST \
		YETI_DB_PORT \
		CDR_DB_HOST \
		CDR_DB_PORT

debuild_flags := $(foreach e,$(debuild_env),-e '$e') $(if $(findstring yes,$(lintian)),--lintian,--no-lintian)
export no_proxy := 127.0.0.1,localhost

pgq_drop_roles :=	DROP ROLE IF EXISTS pgq_reader; \
			DROP ROLE IF EXISTS pgq_writer; \
			DROP ROLE IF EXISTS pgq_admin;

pgq_create_roles :=	CREATE ROLE pgq_reader; \
			CREATE ROLE pgq_writer; \
			CREATE ROLE pgq_admin in role pgq_reader,pgq_writer;

define info
       @printf '\n\e[33m> msg \e[0m\n\n'
endef

###### Rules ######
.PHONY: all
all: docs assets pgq-processors-gems swagger


debian/changelog:
	$(info:msg=Generating changelog)
	changelog-gen -p "$(pkg_name)" -d "$(debian_host_release)" -A "s/_/~/g" "s/-master/~master/" "s/-rc/~rc/"


version.yml: debian/changelog
	$(info:msg=Create version file (version: $(version), commit: $(commit)))
	@echo "version: $(version)" > $@
	@echo "commit: $(commit)" >> $@


config/database.yml:
	$(info:msg=Creating database.yml for build/tests)
	cp config/database.build.yml config/database.yml


config/yeti_web.yml:
	$(info:msg=Creating yeti_web.yml for build/tests)
	@# explicitly raise error during tests if policy is misconfigured
	sed -E 's/( +when_no_(config|policy_class): *)(.*)/\1raise/' \
		config/yeti_web.yml.distr > config/yeti_web.yml


config/policy_roles.yml:
	$(info:msg=Creating policy_roles.yml for build/tests)
	cp config/policy_roles.yml.distr config/policy_roles.yml


.PHONY: bundler
bundler:
	$(info:msg=Install bundler)
	gem install --no-document --install-dir $(gems) bundler -v 2.1.4


.PHONY: gems
gems: bundler
	$(info:msg=Install/Update gems)
	$(bundle_bin) install --jobs=4 --deployment --without development test
	$(bundle_bin) clean


.PHONY: gems-test
gems-test: bundler
	$(info:msg=Install/Update gems for tests)
	$(bundle_bin) install --jobs=4 --deployment --with development test
	$(bundle_bin) clean
	$(bundle_bin) binstubs rspec-core


.PHONY: docs
docs: gems-test config/database.yml config/yeti_web.yml config/policy_roles.yml
	$(info:msg=Preparing test database for docs generation)
	RAILS_ENV=test $(bundle_bin) exec rake \
		db:drop \
		db:create \
		db:structure:load \
		db:migrate \
		db:second_base:drop:_unsafe \
		db:second_base:create \
		db:second_base:structure:load \
		db:second_base:migrate \
		db:seed
	$(info:msg=Generating documentation)
	RAILS_ENV=test $(bundle_bin) exec rake docs:generate
	RAILS_ENV=test $(bundle_bin) exec rake db:drop
	RAILS_ENV=test $(bundle_bin) exec rake db:second_base:drop:_unsafe


.PHONY: assets
assets:	gems config/database.yml config/yeti_web.yml config/policy_roles.yml
	$(info:msg=Precompile assets)
	RAILS_ENV=production $(bundle_bin) exec rake assets:precompile


.PHONY: pgq-processors-gems
pgq-processors-gems:
	$(info:msg=call pgq-processors processing)
	$(MAKE) -C pgq-processors


.PHONY: swagger
swagger: debian/changelog
	$(info:msg=call swagger processing)
	$(MAKE) -C swagger version=${version}


.PHONY: prepare-test-db
prepare-test-db: gems-test config/database.yml config/yeti_web.yml config/policy_roles.yml
	$(info:msg=Preparing test database)
	RAILS_ENV=test $(bundle_bin) exec rake \
		parallel:drop \
		parallel:rake[db:second_base:drop:_unsafe]
	@# avoid race condition when createing pgq roles in parallel with
	@# parallel:spec
	@# https://github.com/pgq/pgq/blob/master/functions/pgq.upgrade_schema.sql
	psql -h db -U postgres -c '$(pgq_drop_roles)'
	psql -h db -U postgres -c '$(pgq_create_roles)'
	RAILS_ENV=test $(bundle_bin) exec rake  \
		parallel:create \
		parallel:rake[db:second_base:create]
	RAILS_ENV=test $(bundle_bin) exec rake \
		parallel:load_structure \
		parallel:rake[db:second_base:structure:load]
	RAILS_ENV=test $(bundle_bin) exec rake parallel:rake[db:seed]


.PHONY: test
test: test-pgq-processors lint rspec


.PHONY: rspec
rspec: gems-test config/database.yml config/yeti_web.yml config/policy_roles.yml prepare-test-db
ifdef spec
	$(info:msg=Testing spec $(spec))
	RAILS_ENV=test $(bundle_bin) exec rspec "$(spec)"
else
	$(info:msg=Running rspec tests)
	RAILS_ENV=test $(bundle_bin) exec parallel_test \
		  spec/ \
		  --type rspec \
		  $(if $(TEST_GROUP),--only-group $(TEST_GROUP),) \
		  && script/format_runtime_log log/parallel_runtime_rspec.log \
		  || { script/format_runtime_log log/parallel_runtime_rspec.log; false; }
endif


.PHONY: lint
lint: gems-test config/database.yml config/yeti_web.yml
	$(info:msg=Running rubocop and bundle audit)
	RAILS_ENV=test $(bundle_bin) exec rubocop -P
	RAILS_ENV=test $(bundle_bin) exec rake bundle:audit


.PHONY: test-pgq-processors
test-pgq-processors: config/database.yml config/yeti_web.yml config/policy_roles.yml
	$(info:msg=Preparing test database for pgq-processors)
	@# PGQ_PROCESSORS_TEST is used in database_build.yml to setup separate db
	@# to not interfere with main test suite when running make tasks in parallel
	RAILS_ENV=test PGQ_PROCESSORS_TEST=true $(bundle_bin) exec rake \
		db:drop \
		db:create \
		db:structure:load \
		db:migrate \
		db:second_base:drop:_unsafe \
		db:second_base:create \
		db:second_base:structure:load \
		db:second_base:migrate \
		db:seed
	$(info:msg=Run pgq-processors tests)
	$(MAKE) -C pgq-processors test
	RAILS_ENV=test PGQ_PROCESSORS_TEST=true $(bundle_bin) exec rake \
		db:drop \
		db:second_base:drop:_unsafe


.PHONY: install
install: $(app_files)
	$(info:msg=install app files)
	@mkdir -p $(DESTDIR)$(app_dir)
	tar -c --no-auto-compress $(addprefix --exclude , $(exclude_files)) $^ | tar -x -C $(DESTDIR)$(app_dir)
	@mkdir -v -p $(addprefix $(DESTDIR)$(app_dir)/, log tmp )

	$(info:msg=install swagger specs)
	@$(MAKE) -C swagger install DESTDIR=$(DESTDIR)$(app_dir)/public version=$(version)
	@install -v -m0644 -D debian/$(pkg_name).rsyslog $(DESTDIR)/etc/rsyslog.d/$(pkg_name).conf
	@install -v -m0644 -d $(DESTDIR)/var/log/yeti


.PHONY: clean
clean:
	$(info:msg=Cleaning)
	$(MAKE) -C swagger clean
	$(MAKE) -C pgq-processors clean
	rm -rf 	public/assets \
		.bundle \
		doc/api
	rm -fv 	config/database.yml \
		config/yeti_web.yml \
		config/policy_roles.yml
	rm -fv bin/rspec


.PHONY: clean-all
clean-all:
	$(info:msg=Cleaning everything)
	-@debian/rules clean
	rm -rf $(gems)
	rm -rf $(bundler_gems)
	rm -rf .bundle
	rm -f $(version_file)
	rm -f debian/changelog

.PHONY: package
package: debian/changelog
	$(info:msg=Building package)
	debuild $(debuild_flags) -uc -us -b
