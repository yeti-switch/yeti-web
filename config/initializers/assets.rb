# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w[yeti/*]
Rails.application.config.assets.precompile += %w[.svg .eot .woff .ttf]

# Fixes bug when precompile tom-select-rails/css/tom-select.css:
# SassC::SyntaxError:
#   Error: "var(--ts-pr-caret)" is not a number for `max'
#           on line 227:10 of stdin, in function `max`
#           from line 227:10 of stdin
#   >>   right: max(var(--ts-pr-caret), 8px);
# https://github.com/alphagov/govuk-frontend/issues/1350
# https://github.com/sass/sassc-rails/issues/93
# Side
Rails.application.config.assets.css_compressor = nil
Rails.application.config.sass.style = :compact
