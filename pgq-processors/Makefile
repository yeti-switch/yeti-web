define info
	echo -e '\n\e[33m> msg \e[39m\n'
endef

all:
	GEM_PATH=../.gem make all_env

all_env:
	@$(info:msg=install/update gems)
	@../.gem/bin/bundle install

clean:
	rm -rf .bundle_gem

