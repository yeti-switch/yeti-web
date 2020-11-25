# frozen_string_literal: true

RSpec.shared_context :timezone_helpers do
  let(:server_time_zone) { ActiveSupport::TimeZone.new Rails.application.config.time_zone }
  let(:utc_timezone) { System::Timezone.find_by!(abbrev: 'UTC') }
  let(:la_timezone) { FactoryBot.create(:timezone, :los_angeles) }
  let(:kiev_timezone) { FactoryBot.create(:timezone, :kiev) }
end
