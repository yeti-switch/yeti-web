# frozen_string_literal: true

RSpec.shared_context :stub_calculate_period_current_time do
  # let(:account_time_zone) { ActiveSupport::TimeZone.new(account.timezone.name) }
  # let(:current_account_time) { account_time_zone.parse('2020-01-01 00:00:00') }

  before do
    allow(BillingInvoice::CalculatePeriod).to receive(:time_zone_for)
      .with(account.timezone.name)
      .and_return(account_time_zone)

    allow(account_time_zone).to receive(:now)
      .with(no_args)
      .and_return(current_account_time)
  end
end
