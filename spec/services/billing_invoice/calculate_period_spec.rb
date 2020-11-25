# frozen_string_literal: true

RSpec.describe BillingInvoice::CalculatePeriod, '.time_zone_for' do
  subject do
    described_class.time_zone_for(account_timezone.name)
  end

  include_context :timezone_helpers

  context 'with UTC timezone' do
    let(:account_timezone) { utc_timezone }

    it { is_expected.to be_a_kind_of(ActiveSupport::TimeZone) }
    it { expect(subject.name).to eq(account_timezone.name) }
  end

  context 'with Kiev timezone' do
    let(:account_timezone) { kiev_timezone }

    it { is_expected.to be_a_kind_of(ActiveSupport::TimeZone) }
    it { expect(subject.name).to eq(account_timezone.name) }
  end

  context 'with LA timezone' do
    let(:account_timezone) { la_timezone }

    it { is_expected.to be_a_kind_of(ActiveSupport::TimeZone) }
    it { expect(subject.name).to eq(account_timezone.name) }
  end

  # enable when remove invalid timezones
  xcontext 'test all timezones from seeds' do
    before do
      System::Timezone.delete_all

      sys_sql = File.read Rails.root.join('db/seeds/main/sys.sql')
      inserts = sys_sql.split("\n").select { |line| line.start_with?('INSERT INTO sys.timezones') }
      SqlCaller::Yeti.execute inserts.join(";\n").to_s
    end
    after do
      System::Timezone.delete_all

      # from spec/fixtures/sys.timezones.yml
      System::Timezone.create!(
          id: 1,
          name: 'UTC',
          abbrev: 'UTC',
          utc_offset: '00:00:00',
          is_dst: false
        )
    end

    it 'generates correct TimeZone objects', :aggregate_failures do
      expect(System::Timezone.count).to eq(1_214)

      System::Timezone.all.each do |timezone|
        subject = described_class.time_zone_for(timezone.name)
        expected = ActiveSupport::TimeZone.new(timezone.name)
        expect(subject).to(
            be_present,
            -> { "expect time zone for #{timezone.name} to be present, but it doesn't" }
          )
        expect(subject).to(
            eq(expected),
            -> { "expect #{subject.inspect} to eq #{expected.inspect}, but it doesn't" }
          )
      end
    end
  end
end
