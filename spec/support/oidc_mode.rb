# frozen_string_literal: true

# activeadmin-oidc 2.x ships `ActiveAdmin::Oidc::TestHelpers` (stub_oidc_sign_in,
# stub_oidc_failure, reset_oidc_stubs) but, unlike 0.1.0, no longer auto-installs
# RSpec tag filtering for `oidc_mode: true` — the gem's README now says to wire
# this up in the host's rails_helper ourselves. This file is that wiring, plus
# the skip-when-not-in-OIDC-mode guard the old gem used to provide.
require 'activeadmin/oidc/test_helpers'

RSpec.configure do |config|
  config.include ActiveAdmin::Oidc::TestHelpers, oidc_mode: true
  config.after(:each, :oidc_mode) { reset_oidc_stubs }

  # `oidc_mode: true` specs need config/oidc.yml in place (AdminUser gets
  # :omniauthable only then — see AdminUser.oidc_config_exists?).
  #
  # Locally, skip them rather than fail when it's absent, so the regular suite
  # stays green without it. In the dedicated CI OIDC job (CI_RUN_OIDC=true)
  # these are the *only* specs that run, so skipping them all would turn a
  # broken setup into a green run that tested nothing — fail loudly instead.
  config.before(:each, :oidc_mode) do
    next if AdminUser.oidc?

    message = 'requires OIDC mode (run with config/oidc.yml in place and CI_RUN_OIDC=true)'
    raise message if ENV['CI_RUN_OIDC'].present?

    skip message
  end

  # CI runs OIDC specs in a dedicated job (config/oidc.yml + CI_RUN_OIDC=true)
  # so the regular job — which has neither — doesn't also try to run them.
  if ENV['CI_RUN_OIDC'].present?
    config.filter_run_including oidc_mode: true
  else
    config.filter_run_excluding oidc_mode: true
  end
end
