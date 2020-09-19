## Welcome to YETI
[![Build Status](https://api.travis-ci.org/yeti-switch/yeti-web.svg?branch=master)](https://travis-ci.org/yeti-switch/yeti-web)

[![Coverage Status](https://coveralls.io/repos/github/yeti-switch/yeti-web/badge.svg?branch=master)](https://coveralls.io/github/yeti-switch/yeti-web?branch=master)


# Contributing, Development setup


It is strongly recommended to use PostgreSQL version 11.
The easiest way to install it - is to use Debian Linux and follow official PostgreSQL instruction
https://www.postgresql.org/download/linux/debian/

You need to install:

```sh
sudo apt-get install postgresql-11 postgresql-contrib-11 postgresql-11-prefix postgresql-11-pgq3 postgresql-11-pgq-ext postgresql-11-yeti
sudo apt-get install -t stretch-pgdg libpq-dev
```
In addition you need to compile or install from .deb package Yeti PostgreSQL extension https://github.com/yeti-switch/yeti-pg-ext

Then fork and clone yeti-web repository and run:

```sh
bundle install
```

Then create `config/database.yml`, example is `database.yml.example`. Notice this project uses two databases main "yeti" and second database "cdr"

Then create `config/yeti_web.yml`, example is `config/yeti_web.yml.distr`.

And run command to create development database:

```sh
RAILS_ENV=development bundle exec rake db:create db:structure:load db:migrate
RAILS_ENV=development bundle exec rake db:second_base:create db:second_base:structure:load db:second_base:migrate
RAILS_ENV=development bundle exec rake db:seed
```

Then start rails server `bundle exec rails s` and login to http://localhost:3000/ with
login `admin` and password `111111`

Then prepare test database(do not use db:test:prepare).

```sh
RAILS_ENV=test bundle exec rake db:drop db:create db:structure:load db:migrate
RAILS_ENV=test bundle exec rake db:second_base:drop:_unsafe db:second_base:create db:second_base:structure:load db:second_base:migrate
RAILS_ENV=test bundle exec rake db:seed
```

This project has CDR-database, configured as SecondDatabase
https://github.com/customink/secondbase
And all commands should be run explicitly by calling "db:second_base:*" commands.

NOTICE: Test DB needs seeds, actually only PGQ seed.

And run tests:

```sh
bundle exec rspec
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

## Migrations that insert rows into yeti database

```bash
RAILS_ENV=test bundle exec rake db:create db:structure:load
RAILS_ENV=test bundle exec rake db:second_base:create db:second_base:structure:load
RAILS_ENV=test bundle exec rake db:seed
# create migration inside db/migrations
RAILS_ENV=test bundle exec rake db:migrate
# SCHEMA_NAME - schema of table into which you've inserted row(s)
# YETI_TEST_DB_NAME - yeti test database name on local machine
pg_dump --column-inserts --data-only --schema=sys --file=db/seeds/main/SCHEMA_NAME.sql YETI_TEST_DB_NAME
```

## Use Docker Postgres for development

For development purpouse it is convinient to use PostgreSQL from Docker image. Here is the instruction how to set it up-and-running:

* Install Docker(Ubuntu example)

  [Install Docker on Ubuntu 18.10](https://www.thecodecampus.de/blog/install-docker-on-ubuntu-18-10/)

* Run following commands in terminal from `yeti-web` projects directory

  ```
  sudo docker build -t yeti_postgres -f ci/pgsql.Dockerfile .
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

* Initialize database with instructions described in [Contributing, Development setup](#contributing-development-setup) section(db:create, db:structure:load, etc.)
