# frozen_string_literal: true

RSpec.configure do |config|
  # OIDC mode is selected at class-load time by presence of config/oidc.yml.
  # Tests tagged :oidc_mode require the real AdminUser to have been loaded
  # with AdminUserOidcHandler — otherwise skip cleanly.
  config.before(:each, :oidc_mode) do
    unless AdminUser.oidc?
      skip 'requires OIDC mode (run with config/oidc.yml in place and CI_RUN_OIDC=true)'
    end
  end

  # Allow running OIDC specs on a dedicated CI job analogous to LDAP:
  #   CI_RUN_OIDC=true bundle exec rspec
  if ENV['CI_RUN_OIDC'].present?
    config.filter_run_including :oidc_mode
  else
    config.filter_run_excluding :oidc_mode
  end
end
