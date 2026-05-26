# frozen_string_literal: true

# Ensures Doorkeeper + MCP routes are mounted for the duration of the spec.
# Use when running specs in an environment where yeti_web.yml might have
# oauth/mcp disabled (e.g. CI loading yeti_web.yml.ci).
RSpec.shared_context :with_oauth_routes do
  before(:all) do
    @__original_oauth_enabled = YetiConfig.oauth&.enabled
    @__original_mcp_enabled = YetiConfig.mcp&.enabled
    allow(YetiConfig).to receive(:oauth).and_return(OpenStruct.new(enabled: true)) if YetiConfig.oauth.nil? || !YetiConfig.oauth.enabled
    allow(YetiConfig).to receive(:mcp).and_return(OpenStruct.new(enabled: true)) if YetiConfig.mcp.nil? || !YetiConfig.mcp.enabled
    Rails.application.reload_routes!
  end
end

# Variant: explicitly disabled, for testing the gating.
RSpec.shared_context :with_oauth_routes_disabled do
  before do
    allow(YetiConfig).to receive(:oauth).and_return(OpenStruct.new(enabled: false))
    allow(YetiConfig).to receive(:mcp).and_return(OpenStruct.new(enabled: false))
    Rails.application.reload_routes!
  end

  after do
    Rails.application.reload_routes!
  end
end
