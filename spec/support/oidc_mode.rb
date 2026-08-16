# frozen_string_literal: true

require 'activeadmin/oidc/test_helpers'

# activeadmin-oidc ships the helpers as a bare module and does NOT install them:
# the `RSpec.configure` block in lib/activeadmin/oidc/test_helpers.rb is a
# comment showing host apps what to write. (This file previously claimed the gem
# auto-installed tag filtering and hooks — that came from the gem's git master,
# and the ActiveAdmin 4 upgrade pinned the released `~> 2.1`, which does not.)
#
# Whether the admin runs on OIDC is a boot-time decision, not a per-example one:
# AdminUser.external_auth? reads config/oidc.yml, and app/admin/system/admin_users.rb
# consults it while registering the resource — `actions` there drops :new, and
# the password inputs are omitted from the form. Nothing an example does at
# runtime can change that.
#
# So `oidc_mode: true` specs only make sense in the dedicated OIDC run:
# .github/workflows/tests.yml's `rspec_oidc` job copies config/oidc.yml.distr
# into place and then runs the whole suite. Exclude them everywhere else instead
# of letting them assert OIDC behaviour against a password-auth admin.
#
# To run them locally: `cp config/oidc.yml.distr config/oidc.yml` (and remove it
# to go back to the default suite).
RSpec.configure do |config|
  config.include ActiveAdmin::Oidc::TestHelpers, oidc_mode: true
  config.after(:each, :oidc_mode) { reset_oidc_stubs }

  config.filter_run_excluding(oidc_mode: true) unless AdminUser.external_auth?
end
