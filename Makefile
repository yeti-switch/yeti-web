pkg_name = yeti-web
user = yeti-web
app_dir = /home/$(user)

version = $(shell dpkg-parsechangelog --help | grep -q '\--show-field' \
	&& dpkg-parsechangelog --show-field version \
	|| dpkg-parsechangelog | grep Version | awk '{ print $$2; }')
commit = $(shell git rev-parse HEAD)
version_file = version.yml

bundle_bin=vendor/bundler/bin/bundle

app_files = bin app .bundle config config.ru db doc Gemfile Gemfile.lock lib public Rakefile vendor pgq-processors $(version_file)

exclude_files = config/database.yml

env_mode = production
database_yml_exists := $(shell test -f config/database.yml && echo "true" || echo "false")
lintian_flag := $(if $(lintian),--lintian,--no-lintian)
debian_host_release != lsb_release -sc

#
# chlog target vars
#
compare_versions = $(shell dpkg --compare-versions "$(1)" "$(2)" "$(3)" && echo true || echo false)

DEBFULLNAME ?= YETI team
DEBMAIL ?= dev@yeti-switch.org
git_first_commmit = $(shell git rev-list --max-parents=0 HEAD)
git_last_commit = $(shell git rev-parse HEAD)

git_version = $(shell git --version | awk '{print $$3}')
ifeq "$(call compare_versions,$(git_version),ge,2.15.0)" "true"
	tag_list = $(shell git \
		   -c versionsort.suffix="-rc" \
		   -c versionsort.suffix="-master" \
		   tag --list "[0-9].*" --sort="v:refname" --merged)
else ifeq "$(call compare_versions,$(git_version),ge,2.7.0)" "true"
	tag_list = $(shell git \
		   -c versionsort.prereleaseSuffix="-rc" \
		   -c versionsort.prereleaseSuffix="-master" \
		   tag --list "[0-9].*" --sort="v:refname" --merged)
else
	tag_list != git log \
		--simplify-by-decoration \
		--decorate \
		--pretty=oneline \
		--reverse | \
		grep -oP 'tag: .+?[,)]' | \
		sed 's/tag: \(.*\)[),]/\1/'
endif

ifneq "$(auto_chlog)" "no"
ifeq "$(words $(tag_list))" "0"
$(error "There are no tags in git to generate changelog from!")
endif
version = $(word $(words $(tag_list)), $(tag_list))
commit_number_since_release := $(shell git rev-list HEAD "^$(version)" | wc -l)
tag_list += HEAD
endif

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
	RAILS_ENV=test $(bundle_bin) exec rake db:second_base:drop db:second_base:create db:second_base:structure:load db:second_base:migrate
	RAILS_ENV=test $(bundle_bin) exec rake db:seed

	git checkout db/structure.sql db/secondbase/structure.sql

	@$(info:msg=Generating documentation)
	RAILS_ENV=test $(bundle_bin) exec rake docs:generate

	@$(info:msg=Clean GEMS and bundler config)
	rm -rf .bundle vendor/bundler vendor/bundle


.PHONY: all_env
all_env: bundler pgq-processors swagger
	@$(info:msg=install gems for production mode)
	@$(bundle_bin) install --jobs=4 --frozen --deployment --binstubs --without development test
	
	@$(info:msg=generating bin/delayed_job)
	@$(bundle_bin) exec rails generate delayed_job

	@$(info:msg=precompile assets)
	@$(bundle_bin) exec ./bin/rake assets:precompile


.PHONY: version.yml
version.yml: debian/changelog
	@$(info:msg=create version file (version: $(version), commit: $(commit)))
	@echo "version:" $(version) "\ncommit:" $(commit) > $(version_file)


.PHONY: bundler
bundler:
	@$(info:msg=install bundler)
	@gem install --no-document --install-dir vendor/bundler bundler


.PHONY: pgq_preprocessors
pgq_preprocessors:
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
package: chlog
	debuild $(lintian_flag) -e http_proxy -e https_proxy -uc -us -b


.PHONY: chlog
chlog: clean-chlog
ifeq "$(auto_chlog)" "no"
	@$(info:msg=Skipping changelog generation)
else
	@$(info:msg=Generating changelog Supply auto_chlog=no to skip.)
	@which changelog-git || { $(err:msg=Failed to generate changelog. Did you install git-changelog package?) && false; }
	PREV="$(git_first_commmit)"; for tag in $(tag_list); do \
		NEXT="$$tag"; \
		[ "$$tag" != "HEAD" ] && ver="$$NEXT"; \
		[ "$$tag" = "HEAD" ] && ver="$$PREV+$(commit_number_since_release)"; \
		[ "$$tag" = "HEAD" ] && [ $(commit_number_since_release) -eq 0 ] && continue; \
		ver="$$(echo $$ver | sed 's/-rc/~rc/' | sed 's/-master/~master/')"; \
		echo "Appending version $${ver} from $${PREV} to $${NEXT}"; \
		changelog-git \
			-q \
			--from-commit="$$PREV" \
			--to-commit="$$NEXT" \
			--next-version="$$ver" \
			--debian-branch="$(debian_host_release)" \
			--package-name="$(pkg_name)" \
			--user-name="$(DEBFULLNAME)" \
			--user-email="$(DEBMAIL)"; \
		PREV="$$NEXT"; \
	done
endif


.PHONY: clean-chlog
clean-chlog:
ifneq "$(auto_chlog)" "no"
	@$(info:msg=Removing changelog)
	@rm -vf debian/changelog
endif

