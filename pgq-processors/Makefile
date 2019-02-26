define info
	echo -e '\n\e[33m> msg \e[39m\n'
endef

all:
	GEM_PATH=vendor/bundler make all_env

all_env:
	@$(info:msg=PGQ: install bundler)
	@gem install --install-dir vendor/bundler bundler -v '< 2'

	@$(info:msg=PGQ: install gems)
	@vendor/bundler/bin/bundle install --jobs=4 --frozen --deployment --binstubs

clean:
	@$(info:msg=PGQ. removing bundler and gems)
	rm -rf vendor/bundler vendor/bundle

