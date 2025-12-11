# frozen_string_literal: true

RSpec.describe BillingInvoice::CalculatePeriod, '.time_zone_for' do
  subject do
    described_class.time_zone_for(account_timezone)
  end

  include_context :timezone_helpers

  context 'with UTC timezone' do
    let(:account_timezone) { utc_timezone }

    it { is_expected.to be_a_kind_of(ActiveSupport::TimeZone) }
    it { expect(subject.name).to eq(account_timezone) }
  end

  context 'with Kyiv timezone' do
    let(:account_timezone) { kyiv_timezone }

    it { is_expected.to be_a_kind_of(ActiveSupport::TimeZone) }
    it { expect(subject.name).to eq(account_timezone) }
  end

  context 'with LA timezone' do
    let(:account_timezone) { la_timezone }

    it { is_expected.to be_a_kind_of(ActiveSupport::TimeZone) }
    it { expect(subject.name).to eq(account_timezone) }
  end

  context 'test all timezones from Yeti::TimeZoneHelper' do
    it 'generates correct TimeZone objects for all timezones', :aggregate_failures do
      Yeti::TimeZoneHelper.all.each do |timezone_name|
        subject = described_class.time_zone_for(timezone_name)
        expected = ActiveSupport::TimeZone.new(timezone_name)
        expect(subject).to(
            be_present,
            -> { "expect time zone for #{timezone_name} to be present, but it doesn't" }
          )
        expect(subject).to(
            eq(expected),
            -> { "expect #{subject.inspect} to eq #{expected.inspect}, but it doesn't" }
          )
      end
    end
  end
end
