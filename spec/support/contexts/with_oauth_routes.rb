# frozen_string_literal: true

# OAuth + MCP routes are enabled for the whole suite via yeti_web.yml.ci
# (which sets oauth.enabled and mcp.enabled to true). This shared context is
# now a no-op kept only for clarity / call-site documentation. Specs that
# need the disabled state should use :with_oauth_routes_disabled instead.
RSpec.shared_context :with_oauth_routes do
end

# Variant: explicitly disabled, for testing the gating. Mutates YetiConfig
# directly rather than stubbing because rspec-mocks tears down stubs AFTER
# `after` hooks fire — so `reload_routes!` in `after` would re-read the
# still-stubbed (disabled) value and leak the missing routes into the next
# spec.
RSpec.shared_context :with_oauth_routes_disabled do
  before do
    @__orig_oauth_enabled = YetiConfig.oauth.enabled
    @__orig_mcp_enabled = YetiConfig.mcp.enabled
    YetiConfig.oauth.enabled = false
    YetiConfig.mcp.enabled = false
    Rails.application.reload_routes!
  end

  after do
    YetiConfig.oauth.enabled = @__orig_oauth_enabled
    YetiConfig.mcp.enabled = @__orig_mcp_enabled
    Rails.application.reload_routes!
  end
end
