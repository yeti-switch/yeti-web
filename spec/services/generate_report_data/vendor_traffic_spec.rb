# frozen_string_literal: true

RSpec.describe GenerateReportData::VendorTraffic do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) do
    { report: report }
  end

  let!(:smtp_connection) { FactoryBot.create(:smtp_connection) }
  let!(:vendor) do
    FactoryBot.create(:vendor)
  end
  let!(:customers) do
    FactoryBot.create_list(:customer, 3)
  end
  let!(:report) do
    FactoryBot.create(:vendor_traffic, report_attrs)
  end
  let(:report_attrs) do
    {
      date_start: Time.parse('2019-02-15'),
      date_end: Time.parse('2019-02-16'),
      vendor: vendor
    }
  end

  before do
    Cdr::Cdr.add_partition_for Time.parse('2019-02-14')
    Cdr::Cdr.add_partition_for Time.parse('2019-02-15')
    Cdr::Cdr.add_partition_for Time.parse('2019-02-16')

    # not included CDR
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-14 23:59:59'))
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-16 00:00:00'))

    vendor2 = FactoryBot.create(:vendor)
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), vendor: vendor2)
  end

  let!(:cdrs) do
    [
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), vendor: vendor, customer: customers.first),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), vendor: vendor, customer: customers.first),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), vendor: vendor, customer: customers.first)
    ]
  end

  it 'creates vendor traffic data' do
    expect { subject }.to change { Report::VendorTrafficData.count }.by(1)
    report = Report::VendorTrafficData.last!
    expect(report).to have_attributes(calls_count: 3)
  end

  it 'does not create email log' do
    expect { subject }.to change { ::Log::EmailLog.count }.by(0)
  end

  context 'when cdrs belongs to different customers' do
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), vendor: vendor, customer: customers.first),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), vendor: vendor, customer: customers.second),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), vendor: vendor, customer: customers.first)
      ]
    end

    it 'creates vendor traffic data' do
      expect { subject }.to change { Report::VendorTrafficData.count }.by(2)
      reports = Report::VendorTrafficData.all.last(2)
      expect(reports.map(&:calls_count)).to match_array [2, 1]
    end

    it 'does not create email log' do
      expect { subject }.to change { ::Log::EmailLog.count }.by(0)
    end
  end

  context 'when there are no CDRs for date_start - date_end' do
    let!(:cdrs) { nil }

    it 'does not create custom data' do
      expect { subject }.to change { Report::CustomData.count }.by(0)
    end
  end

  context 'when report has send_to' do
    let(:report_attrs) do
      super().merge send_to: contacts.map(&:id)
    end
    let!(:contacts) do
      FactoryBot.create_list(:contact, 2)
    end

    before do
      # not used contact
      FactoryBot.create(:contact)
    end

    it 'creates vendor traffic data' do
      expect { subject }.to change { Report::VendorTrafficData.count }.by(1)
      report = Report::VendorTrafficData.last!
      expect(report).to have_attributes(calls_count: 3)
    end

    it 'creates correct email logs' do
      expect { subject }.to change { ::Log::EmailLog.count }.by(2)
      expect(
        ::Log::EmailLog.where(contact_id: contacts.first.id, smtp_connection_id: contacts.first.smtp_connection.id).count
      ).to eq 1
      expect(
        ::Log::EmailLog.where(contact_id: contacts.second.id, smtp_connection_id: contacts.first.smtp_connection.id).count
      ).to eq 1
    end
  end

  context 'when report already completed' do
    let(:report_attrs) do
      super().merge completed: true
    end

    it 'does not create custom data' do
      expect { safe_subject }.to change { Report::CustomData.count }.by(0)
    end

    include_examples :raises_exception, GenerateReportData::CustomCdr::Error
  end
end
