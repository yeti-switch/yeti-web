# frozen_string_literal: true

RSpec.describe BillingPeriod::SemiMonthly do
  include_context :timezone_helpers

  let(:timezone) { utc_timezone }
  let(:time_zone) { ActiveSupport::TimeZone.new(timezone) }

  shared_examples :calculates_period do |date:, period_end:, period_start:|
    context "when date is #{date}" do
      it "returns period_end #{period_end}" do
        time = time_zone.parse("#{date} 12:34:56")
        expect(described_class.period_end_for(time_zone, time)).to eq(time_zone.parse("#{period_end} 00:00:00"))
      end

      it "returns period_start #{period_start} for period_end #{period_end}" do
        time = time_zone.parse("#{period_end} 00:00:00")
        expect(described_class.period_start_for(time_zone, time)).to eq(time_zone.parse("#{period_start} 00:00:00"))
      end
    end
  end

  shared_examples :semi_monthly_periods do
    # first half of month
    include_examples :calculates_period, date: '2020-03-01', period_end: '2020-03-16', period_start: '2020-03-01'
    include_examples :calculates_period, date: '2020-03-15', period_end: '2020-03-16', period_start: '2020-03-01'
    # second half of month
    include_examples :calculates_period, date: '2020-03-16', period_end: '2020-04-01', period_start: '2020-03-16'
    include_examples :calculates_period, date: '2020-03-31', period_end: '2020-04-01', period_start: '2020-03-16'
    # 30 days month
    include_examples :calculates_period, date: '2020-04-30', period_end: '2020-05-01', period_start: '2020-04-16'
    # february of leap year
    include_examples :calculates_period, date: '2020-02-29', period_end: '2020-03-01', period_start: '2020-02-16'
    # february of non leap year
    include_examples :calculates_period, date: '2019-02-28', period_end: '2019-03-01', period_start: '2019-02-16'
    # end of year
    include_examples :calculates_period, date: '2020-12-16', period_end: '2021-01-01', period_start: '2020-12-16'
  end

  include_examples :semi_monthly_periods

  context 'when time zone is LA' do
    let(:timezone) { la_timezone }

    include_examples :semi_monthly_periods
  end

  it 'is not a split period' do
    expect(described_class.split_period?).to eq(false)
  end
end
