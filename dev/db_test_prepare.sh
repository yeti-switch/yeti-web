#!/bin/bash

echo "prepare test databases..."

RAILS_ENV=test SEED_WORKERS=4 bundle exec rake db:drop \
                                db:create \
                                db:schema:load \
                                db:seed \
                                custom_seeds[network_prefixes]
