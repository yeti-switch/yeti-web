pkg_name = yeti-web
user = yeti-web
app_dir = /opt/$(user)

version = $(shell dpkg-parsechangelog --help | grep -q '\--show-field' \
	&& dpkg-parsechangelog --show-field version \
	|| dpkg-parsechangelog | grep Version | awk '{ print $$2; }')
commit = $(shell git rev-parse HEAD)
version_file := version.yml

bundle_bin=vendor/bundler/bin/bundle

app_files = bin app .bundle config config.ru db doc Gemfile Gemfile.lock lib public Rakefile vendor pgq-processors $(version_file)

exclude_files = config/database.yml *.o *.a

env_mode = production
database_yml_exists := $(shell test -f config/database.yml && echo "true" || echo "false")
lintian_flag := $(if $(lintian),--lintian,--no-lintian)
debian_host_release != lsb_release -sc
export DEBFULLNAME ?= YETI team
export DEBEMAIL ?= dev@yeti-switch.org

#
# funcs
#
define info
	echo -e '\n\e[33m> msg \e[39m\n'
endef

define err
	echo -e '\n\e[31m> msg \e[39m\n'
endef

###### Rules ######

.PHONY: all
all: version.yml
	@$(info:msg=init environment)

ifeq "$(database_yml_exists)" "false"
	@cp -v config/database.build.yml config/database.yml
else
	@$(info:msg=Using overridden database.yml)
endif

	RAILS_ENV=$(env_mode) RACK_ENV=$(env_mode) RAKE_ENV=$(env_mode) GEM_PATH=vendor/bundler $(MAKE) docs
	RAILS_ENV=$(env_mode) RACK_ENV=$(env_mode) RAKE_ENV=$(env_mode) GEM_PATH=vendor/bundler $(MAKE) all_env

ifeq "$(database_yml_exists)" "false"
	@rm -vf config/database.yml
endif


.PHONY: docs
docs: bundler
	@$(info:msg=install/update gems for tests)
	@$(bundle_bin) install --jobs=4 --frozen --deployment

	@$(info:msg=Preparing test database)
	RAILS_ENV=test $(bundle_bin) exec rake db:drop db:create db:structure:load db:migrate
	RAILS_ENV=test $(bundle_bin) exec rake db:second_base:drop:_unsafe db:second_base:create db:second_base:structure:load db:second_base:migrate
	RAILS_ENV=test $(bundle_bin) exec rake db:seed

	git checkout db/structure.sql db/secondbase/structure.sql

	@$(info:msg=Generating documentation)
	RAILS_ENV=test $(bundle_bin) exec rake docs:generate

	@$(info:msg=Clean GEMS and bundler config)
	rm -rf .bundle vendor/bundler vendor/bundle


.PHONY: all_env
all_env: bundler pgq_processors swagger
	@$(info:msg=install gems for production mode)
	@$(bundle_bin) install --jobs=4 --frozen --deployment --binstubs --without development test
	
	@$(info:msg=generating bin/delayed_job)
	@$(bundle_bin) exec rails generate delayed_job

	@$(info:msg=precompile assets)
	@$(bundle_bin) exec ./bin/rake assets:precompile


.PHONY: version.yml
version.yml: chlog
	@$(info:msg=create version file (version: $(version), commit: $(commit)))
	@echo "version:" $(version) "\ncommit:" $(commit) > $(version_file)


.PHONY: bundler
bundler:
	@$(info:msg=install bundler)
	@gem install --no-document --install-dir vendor/bundler bundler -v 2.0.2


.PHONY: pgq_processors
pgq_processors:
	@$(info:msg=call pgq-processors processing)
	$(MAKE) -C pgq-processors


.PHONY: swagger
swagger:
	@$(info:msg=call swagger processing)
	$(MAKE) -C swagger version=${version}


.PHONY: install
install: $(app_files)

	@$(info:msg=install app files)
	@mkdir -p $(DESTDIR)$(app_dir)
	tar -c --no-auto-compress $(addprefix --exclude , $(exclude_files)) $^ | tar -x -C $(DESTDIR)$(app_dir)
	@mkdir -v -p $(addprefix $(DESTDIR)$(app_dir)/, log tmp )

	@$(info:msg=install swagger specs)
	@$(MAKE) -C swagger install DESTDIR=$(DESTDIR)$(app_dir)/public version=$(version)

	@$(info:msg=install rsyslogd cfg file)
	@install -v -m0644 -D debian/$(pkg_name).rsyslog $(DESTDIR)/etc/rsyslog.d/$(pkg_name).conf

	@$(info:msg=install logrotate cfg file)
	@install -v -m0644 -D debian/$(pkg_name).logrotate $(DESTDIR)/etc/logrotate.d/$(pkg_name)

	@$(info:msg=install crontab cfg file)
	@install -v -m0644 -D config/$(pkg_name).crontab $(DESTDIR)/etc/cron.d/$(pkg_name)


.PHONY: clean
clean:
	$(MAKE) -C debian clean
	$(MAKE) -C swagger clean
	$(MAKE) -C pgq-processors clean
	rm -rf public/assets $(version_file)
	rm -rf .bundle vendor/bundler vendor/bundle doc/api


.PHONY: package
package: version.yml
	debuild $(lintian_flag) -e http_proxy -e https_proxy -uc -us -b


.PHONY: chlog
chlog: clean-chlog
ifeq "$(auto_chlog)" "no"
	@$(info:msg=Skipping changelog generation)
else
	@$(info:msg=Generating changelog Supply auto_chlog=no to skip.)
	@which changelog-gen || { $(err:msg=Failed to generate changelog. Did you install git-changelog package?) && false; }
	changelog-gen -p "$(pkg_name)" -d "$(debian_host_release)" -A "s/_/~/g" "s/-master/~master/" "s/-rc/~rc/"
endif


.PHONY: clean-chlog
clean-chlog:
ifneq "$(auto_chlog)" "no"
	@$(info:msg=Removing changelog)
	@rm -vf debian/changelog
endif

