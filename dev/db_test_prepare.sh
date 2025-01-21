#!/bin/bash

echo "prepare test databases..."

RAILS_ENV=test bundle exec rake db:drop \
                                db:create \
                                db:schema:load \
                                db:seed \
                                custom_seeds[network_prefixes]
