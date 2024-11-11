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
		$(version_file) \
		vendor/rbenv \
		.ruby-version

exclude_files :=	config/database.yml \
			config/yeti_web.yml \
			config/secrets.yml \
			*.o \
			*.a

version = $(shell ./ci/gen_version.sh)
debian_version = $(shell echo $(version) | sed 's/_/~/' | sed 's/-master/~master/' | sed 's/-rc/~rc/')-1
commit = $(shell git rev-parse HEAD)

debian_host_release != lsb_release -sc
export DEBFULLNAME ?= YETI team
export DEBEMAIL ?= dev@yeti-switch.org
gems := $(CURDIR)/vendor/bundler
bundle_bin := $(gems)/bin/bundle
bundler_gems := $(CURDIR)/vendor/bundle
export GEM_PATH := $(gems):$(bundler_gems)

# must match final destination in debian package
export RBENV_ROOT := $(app_dir)/vendor/rbenv
export PATH := $(RBENV_ROOT)/shims:$(PATH)
rbenv_version = $(file < .ruby-version)

export no_proxy ?= 127.0.0.1,localhost

pgq_drop_roles :=	DROP ROLE IF EXISTS pgq_reader; \
			DROP ROLE IF EXISTS pgq_writer; \
			DROP ROLE IF EXISTS pgq_admin;

pgq_create_roles :=	CREATE ROLE pgq_reader; \
			CREATE ROLE pgq_writer; \
			CREATE ROLE pgq_admin in role pgq_reader,pgq_writer;

export YETI_DB_HOST ?= db

define info
       @printf '\n\e[33m> msg \e[0m\n\n'
endef


###### Rules ######
.PHONY: all
all: docs assets pgq-processors-gems


debian/changelog:
	$(info:msg=Generating changelog)
	dch \
		--create \
		--package "$(pkg_name)" \
		--newversion "$(debian_version)" \
		--distribution "$(debian_host_release)" \
		"Release $(version), commit: $(commit)"


version.yml: debian/changelog
	$(info:msg=Create version file (version: $(version), commit: $(commit)))
	@echo "version: $(version)" > $@
	@echo "commit: $(commit)" >> $@


config/database.yml:
	$(info:msg=Creating database.yml for build/tests)
	cp config/database.build.yml config/database.yml

config/click_house.yml:
	$(info:msg=Creating click_house.yml for tests)
	cp config/click_house.yml.distr config/click_house.yml

config/secrets.yml:
	$(info:msg=Creating master key for test env)
	touch config/credentials/test.key
	echo "3dfebf8475fd661c870bff8cf91f24a8" > config/credentials/test.key

config/yeti_web.yml:
	$(info:msg=Creating yeti_web.yml for build/tests)
	@# explicitly raise error during tests if policy is misconfigured
	sed -E 's/( +when_no_(config|policy_class): *)(.*)/\1raise/' \
		config/yeti_web.yml.ci > config/yeti_web.yml


config/policy_roles.yml:
	$(info:msg=Creating policy_roles.yml for build/tests)
	cp config/policy_roles.yml.distr config/policy_roles.yml


$(RBENV_ROOT)/versions/$(rbenv_version):
	$(info:msg=Installing ruby $(rbenv_version) into $(RBENV_ROOT))
	mkdir -pv "$(RBENV_ROOT)"
	curl -sSL "https://raw.githubusercontent.com/rbenv/ruby-build/master/share/ruby-build/$(rbenv_version)" \
		> "debian/$(rbenv_version)"
	rbenv install "debian/$(rbenv_version)"
	rm "debian/$(rbenv_version)"


.PHONY: ruby
ruby: $(RBENV_ROOT)/versions/$(rbenv_version)


.PHONY: bundler
bundler: ruby
	$(info:msg=Install bundler)
	gem install --no-document --install-dir $(gems) bundler
	$(bundle_bin) config --local clean 'true'
	$(bundle_bin) config --local jobs 4
	$(bundle_bin) config --local deployment 'true'


.PHONY: gems
gems: bundler
	$(info:msg=Install/Update gems)
	$(bundle_bin) config --local --delete with
	$(bundle_bin) config --local --delete without
	$(bundle_bin) config --local without 'development test'
	$(bundle_bin) install


.PHONY: gems-test
gems-test: bundler
	$(info:msg=Install/Update gems for tests)
	$(bundle_bin) config --local --delete with
	$(bundle_bin) config --local --delete without
	$(bundle_bin) config --local with 'development test'
	$(bundle_bin) install
	$(bundle_bin) binstubs rspec-core


.PHONY: docs
docs: gems-test config/database.yml config/yeti_web.yml config/policy_roles.yml config/secrets.yml
	$(info:msg=Preparing test database for docs generation)
	RAILS_ENV=test $(bundle_bin) exec rake \
		db:drop \
		db:create \
		db:schema:load \
		db:migrate \
		db:seed
	RAILS_ENV=test $(bundle_bin) exec rake custom_seeds[network_prefixes]
	$(info:msg=Generating documentation)
	RAILS_ENV=test $(bundle_bin) exec rake docs:generate
	RAILS_ENV=test $(bundle_bin) exec rake db:drop


.PHONY: assets
assets:	gems config/database.yml config/yeti_web.yml config/policy_roles.yml config/secrets.yml
	$(info:msg=Precompile assets)
	RAILS_ENV=production RAILS_COMPILE_ASSETS=true $(bundle_bin) exec rake assets:precompile


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
	RAILS_ENV=test $(bundle_bin) exec rake parallel:drop
	@# avoid race condition when createing pgq roles in parallel with
	@# parallel:spec
	@# https://github.com/pgq/pgq/blob/master/functions/pgq.upgrade_schema.sql
	psql -h "$(YETI_DB_HOST)" -U postgres -c '$(pgq_drop_roles)'
	psql -h "$(YETI_DB_HOST)" -U postgres -c '$(pgq_create_roles)'
	RAILS_ENV=test $(bundle_bin) exec rake parallel:create
	RAILS_ENV=test $(bundle_bin) exec rake parallel:load_schema
	RAILS_ENV=test $(bundle_bin) exec rake parallel:rake[db:seed]
	RAILS_ENV=test $(bundle_bin) exec rake parallel:rake[custom_seeds[network_prefixes]]


.PHONY: test
test: test-pgq-processors lint brakeman rspec


.PHONY: rspec
rspec: gems-test config/database.yml config/yeti_web.yml config/policy_roles.yml prepare-test-db config/click_house.yml config/secrets.yml
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

.PHONY: rspec
database_consistency: gems-test config/database.yml config/yeti_web.yml config/policy_roles.yml config/secrets.yml prepare-test-db
	$(info:msg=Check the consistency of the database constraints with the application validations)
	RAILS_ENV=test $(bundle_bin) exec database_consistency

.PHONY: lint
lint: gems-test config/database.yml config/yeti_web.yml config/secrets.yml
	$(info:msg=Running rubocop and bundle audit)
	RAILS_ENV=test $(bundle_bin) exec rubocop -P
	RAILS_ENV=test $(bundle_bin) exec rake bundle:audit

.PHONY: brakeman
brakeman: gems-test config/database.yml config/yeti_web.yml config/secrets.yml
	$(info:msg=Running brakeman)
	RAILS_ENV=test $(bundle_bin) exec brakeman

.PHONY: coverage_report
coverage_report: gems-test
	$(info:msg=Generate coverage report)
	$(bundle_bin) exec rake coverage:report

.PHONY: test-pgq-processors
test-pgq-processors: config/database.yml config/yeti_web.yml config/policy_roles.yml config/secrets.yml
	$(info:msg=Preparing test database for pgq-processors)
	@# PGQ_PROCESSORS_TEST is used in database_build.yml to setup separate db
	@# to not interfere with main test suite when running make tasks in parallel
	RAILS_ENV=test PGQ_PROCESSORS_TEST=true $(bundle_bin) exec rake \
		db:drop \
		db:create \
		db:schema:load \
		db:migrate \
		db:seed
	$(info:msg=Run pgq-processors tests)
	$(MAKE) -C pgq-processors test
	RAILS_ENV=test PGQ_PROCESSORS_TEST=true $(bundle_bin) exec rake db:drop


vendor/rbenv:
	cp -r "$(RBENV_ROOT)" vendor/


.PHONY: install
install: $(app_files)
	$(info:msg=install app files)
	@mkdir -p $(DESTDIR)$(app_dir)
	tar -c --no-auto-compress $(addprefix --exclude , $(exclude_files)) $^ | tar -x -C $(DESTDIR)$(app_dir)
	@mkdir -v -p $(addprefix $(DESTDIR)$(app_dir)/, log tmp )
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
		config/policy_roles.yml \
		config/secrets.yml
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
	dpkg-buildpackage -uc -us -b
