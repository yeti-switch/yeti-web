## Welcome to YETI
[![Build Status](https://api.travis-ci.org/yeti-switch/yeti-web.svg?branch=master)](https://travis-ci.org/yeti-switch/yeti-web)



# Contributing, Development setup


It is strongly recommended to use PostgreSQL version 9.4.
The easiest way to install it - is to use Debian Linux and follow official PostgreSQL instruction
https://www.postgresql.org/download/linux/debian/

You need to install:

```sh
$ sudo apt-get install postgresql-9.4 postgresql-contrib-9.4 postgresql-9.4-prefix postgresql-9.4-pgq3 skytools3 skytools3-ticker
$ sudo apt-get install -t stretch-pgdg libpq-dev
```
In addition you need to compile or install from .deb package Yeti PostgreSQL extension https://github.com/yeti-switch/yeti-pg-ext

Then fork and clone yeti-web repository and run:

```sh
$ bundle install
```

Then create `config/database.yml`, example is `database.yml.example`. Notice this project uses two databases main "yeti" and second database "cdr"

And run command to create development database:

```sh
$ bundle exec rake db:create db:structure:load db:migrate
$ bundle exec rake db:second_base:create db:second_base:structure:load db:second_base:migrate
$ bundle exec rake db:seed
```

Then start rails server `$ bundle exec rails s` and login to http://localhost:3000/ with
login `admin` and password `111111`

Then prepare test database(do not use db:test:prepare).

```sh
$ RAILS_ENV=test bundle exec rake db:create db:structure:load db:migrate
$ RAILS_ENV=test bundle exec rake db:second_base:create db:second_base:structure:load db:second_base:migrate
$ RAILS_ENV=test bundle exec rake db:seed
```

This project has CDR-database, configured as SecondDatabase
https://github.com/customink/secondbase
And all commands should be run explicitryl by calling "db:second_base:*" commands.

NOTICE: Test DB needs seeds, actually only PGQ seed.

And run tests:

```sh
$ bundle exec rspec
```

# Migrations

When you run several migrations in a row, you may wish to stop at some point. In this case you should add `stop_step` method to the migration:

```ruby
# example /db/migrate/20171105085529_one.rb
def change
  # do something
end

def stop_step
  true
end
```

In this case all migrations after this one will no be performed. To continue migration process you should run `rake db:migrate` command again.

If you do not want to migrate with stops, use env-variable IGNORE_STOPS=true

```sh
IGNORE_STOPS=true bundle exec rake db:migrate
```
