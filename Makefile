
pkg_name = yeti-web
user = yeti-web
app_dir = /home/$(user)

version = $(shell dpkg-parsechangelog --help | grep -q '\--show-field' \
	&& dpkg-parsechangelog --show-field version \
	|| dpkg-parsechangelog | grep Version | awk '{ print $$2; }')
commit = $(shell git rev-parse HEAD)
version_file = version.yml

bundle_bin=vendor/bundler/bin/bundle

app_files = bin app .bundle config config.ru db doc Gemfile Gemfile.lock lib public Rakefile test vendor pgq-processors $(version_file)

exclude_files = config/database.yml

env_mode = production

define info
	echo -e '\n\e[33m> msg \e[39m\n'
endef

define err
	echo -e '\n\e[31m> msg \e[39m\n'
endef

all: version.yml
	@$(info:msg=init environment)
	RAILS_ENV=$(env_mode) RACK_ENV=$(env_mode) RAKE_ENV=$(env_mode) GEM_PATH=vendor/bundler make all_env

all_env:
	@$(info:msg=install bundler)
	@gem install --install-dir vendor/bundler bundler

	@$(info:msg=install/update gems)
	@$(bundle_bin) install --jobs=4 --frozen --deployment --binstubs --without development test
	
	@$(info:msg=generating bin/delayed_job)
	@$(bundle_bin) exec rails generate delayed_job

	@$(info:msg=precompile assets)
	@$(bundle_bin) exec ./bin/rake assets:precompile

	@$(info:msg=call pgq-processors processing)
	make -C pgq-processors

	make swagger

version.yml: debian/changelog
	@$(info:msg=create version file (version: $(version), commit: $(commit)))
	@echo "version:" $(version) "\ncommit:" $(commit) > $(version_file)

swagger:
	@$(info:msg=call swagger processing)
	make -C swagger version=${version}


install: $(app_files)

	@$(info:msg=install app files)
	@mkdir -p $(DESTDIR)$(app_dir)
	tar -c --no-auto-compress $(addprefix --exclude , $(exclude_files)) $^ | tar -x -C $(DESTDIR)$(app_dir)
	@mkdir -v -p $(addprefix $(DESTDIR)$(app_dir)/, log tmp )

	@$(info:msg=install swagger specs)
	@make -C swagger install DESTDIR=$(DESTDIR)$(app_dir)/public version=$(version)

	@$(info:msg=install rsyslogd cfg file)
	@install -v -m0644 -D debian/$(pkg_name).rsyslog $(DESTDIR)/etc/rsyslog.d/$(pkg_name).conf

	@$(info:msg=install logrotate cfg file)
	@install -v -m0644 -D debian/$(pkg_name).logrotate $(DESTDIR)/etc/logrotate.d/$(pkg_name)

	@$(info:msg=install crontab cfg file)
	@install -v -m0644 -D config/$(pkg_name).crontab $(DESTDIR)/etc/cron.d/$(pkg_name)


clean:
	make -C debian clean
	make -C swagger clean
	make -C pgq-processors clean
	rm -rf public/assets $(version_file)
	rm -rf .bundle vendor/bundler vendor/bundle

package:
	 dpkg-buildpackage -us -uc -b

chlog:
	dch -r --nomultimaint -M

.PHONY: all clean install package chlog version.yml swagger
