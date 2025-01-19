#!/bin/bash

echo "prepare and migrate test database..."

RAILS_ENV=test bundle exec rake db:drop \
                                db:create \
                                db:schema:load \
                                db:migrate \
                                db:seed && \
RAILS_ENV=test bundle exec rake custom_seeds[network_prefixes] && \
RAILS_ENV=test bundle exec rake annotate_models
