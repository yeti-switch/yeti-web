# Welcome to YETI
![Tests](https://github.com/yeti-switch/yeti-web/workflows/Tests/badge.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/yeti-switch/yeti-web/badge.svg?branch=master)](https://coveralls.io/github/yeti-switch/yeti-web?branch=master)
[![Made in Ukraine](https://img.shields.io/badge/made_in-ukraine-ffd700.svg?labelColor=0057b7)](https://stand-with-ukraine.pp.ua)


[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-team.svg)](https://stand-with-ukraine.pp.ua)


# Contributing, Development setup

## Ruby

You have to use Ruby version 2.6 with installed bundler.

## Postgresql

It is strongly recommended to use PostgreSQL version 13.
The easiest way to install it - is to use Debian Linux and follow official PostgreSQL instruction
https://www.postgresql.org/download/linux/debian/

You need to install:

```sh
curl https://pkg.yeti-switch.org/key.gpg | sudo apt-key add -
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc	| sudo apt-key add -
sudo add-apt-repository "deb http://pkg.yeti-switch.org/debian/buster unstable main"
sudo add-apt-repository "deb http://deb.debian.org/debian buster main buster non-free"
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main"
sudo apt-get install postgresql-13 postgresql-contrib-13 postgresql-13-prefix postgresql-13-pgq3 postgresql-13-pgq-ext postgresql-13-yeti postgresql-13-pllua
sudo apt-get install -t buster-pgdg libpq-dev
```
In addition you need to compile or install from .deb package Yeti PostgreSQL extension `postgresql-13-yeti` https://github.com/yeti-switch/yeti-pg-ext

## Preparing yeti-web application

Fork and clone yeti-web repository and run:

```sh
bundle install
```

Then create `config/database.yml`, example is `config/database.yml.development`. Notice this project uses two databases main "yeti" and second database "cdr"

Then create `config/yeti_web.yml`, example is `config/yeti_web.yml.development`.

To disable the creation of new versions via paper_trail for some model please fill the array under key `versioning_disable_for_models` in the `config/yeti_web.yml`

Сreate `config/policy_roles.yml`, example is `config/policy_roles.yml.distr` or disable policy feature by changing following lines in `config/yeti_web.yml`:

```yaml
role_policy:
  when_no_config: allow
  when_no_policy_class: allow
```

And run command to create development database:

```sh
RAILS_ENV=development bundle exec rake db:create db:schema:load db:migrate db:seed
```

Then start rails server `bundle exec rails s` and login to http://localhost:3000/ with
login `admin` and password `111111`

Then prepare test database(do not use db:test:prepare).

```sh
RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load db:migrate db:seed
```

This project has CDR-database, configured as cdr
see https://guides.rubyonrails.org/active_record_multiple_databases.html
And all commands should be run explicitly by calling "db:*:cdr" commands.

NOTICE: Test DB needs seeds, actually only PGQ seed.

And run tests:

```sh
bundle exec rspec
```

## Migrations

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

## Migrations that insert rows into yeti database

```bash
RAILS_ENV=test bundle exec rake db:create db:schema:load db:seed
# create migration inside db/migrations
RAILS_ENV=test bundle exec rake db:migrate
# SCHEMA_NAME - schema of table into which you've inserted row(s)
# YETI_TEST_DB_NAME - yeti test database name on local machine
pg_dump --column-inserts --data-only --schema=SCHEMA_NAME --file=db/seeds/main/SCHEMA_NAME.sql YETI_TEST_DB_NAME
```

## Use Docker Postgres for development

For development purpouse it is convinient to use PostgreSQL from Docker image. Here is the instruction how to set it up-and-running:

* Install Docker(Ubuntu example)

  [Install Docker on Ubuntu 18.10](https://www.thecodecampus.de/blog/install-docker-on-ubuntu-18-10/)

* Run following commands in terminal from `yeti-web` projects directory

  ```
  sudo docker build -t yeti_postgres -f ci/pg13.Dockerfile .
  ```

* Start the Postgres Server using docker image, with remapped port to 3010 and volume "yetiPgData" to persist data after docker container stops:

  ```
  sudo docker run -p 3010:5432 --volume yetiPgData:/var/lib/postgresql yeti_postgres
  ```

* Update `config/database.yml` with

  ```yml
  username: postgres
  password:
  port: 3010
  ```

* Initialize database with instructions described in [Contributing, Development setup](#contributing-development-setup) section(db:create, db:schema:load, etc.)
