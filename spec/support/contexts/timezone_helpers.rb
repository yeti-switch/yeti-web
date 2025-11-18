# frozen_string_literal: true

RSpec.shared_context :timezone_helpers do
  let(:server_time_zone) { ActiveSupport::TimeZone.new Rails.application.config.time_zone }
  let(:utc_timezone) { 'UTC' }
  let(:la_timezone) { 'America/Los_Angeles' }
  let(:kyiv_timezone) { 'Europe/Kyiv' }
end
