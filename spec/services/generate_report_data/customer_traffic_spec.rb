# frozen_string_literal: true

RSpec.describe GenerateReportData::CustomerTraffic do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) do
    { report: report }
  end

  let!(:smtp_connection) { FactoryBot.create(:smtp_connection) }
  let!(:customer) do
    FactoryBot.create(:customer)
  end
  let!(:report) do
    FactoryBot.create(:customer_traffic, report_attrs)
  end
  let(:report_attrs) do
    {
      date_start: Time.parse('2019-02-15'),
      date_end: Time.parse('2019-02-16'),
      customer: customer
    }
  end

  before do
    Cdr::Cdr.add_partition_for Time.parse('2019-02-14')
    Cdr::Cdr.add_partition_for Time.parse('2019-02-15')
    Cdr::Cdr.add_partition_for Time.parse('2019-02-16')

    # not included CDR
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-14 23:59:59'))
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-16 00:00:00'))

    customer2 = FactoryBot.create(:customer)
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer: customer2)
  end

  let!(:cdrs) do
    [
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer: customer),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer: customer),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), customer: customer)
    ]
  end

  it 'creates customer traffic data by vendor' do
    expect { subject }.to change { Report::CustomerTrafficDataByVendor.count }.by(1)
    report = Report::CustomerTrafficDataByVendor.last!
    expect(report).to have_attributes(calls_count: 3)
  end

  it 'creates customer traffic data by destination' do
    expect { subject }.to change { Report::CustomerTrafficDataByDestination.count }.by(1)
    report = Report::CustomerTrafficDataByDestination.last!
    expect(report).to have_attributes(calls_count: 3)
  end

  it 'creates customer traffic data full' do
    expect { subject }.to change { Report::CustomerTrafficDataFull.count }.by(1)
    report = Report::CustomerTrafficDataFull.last!
    expect(report).to have_attributes(calls_count: 3)
  end

  it 'does not create email log' do
    expect { subject }.to change { ::Log::EmailLog.count }.by(0)
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

    it 'creates customer traffic data by vendor' do
      expect { subject }.to change { Report::CustomerTrafficDataByVendor.count }.by(1)
      report = Report::CustomerTrafficDataByVendor.last!
      expect(report).to have_attributes(calls_count: 3)
    end

    it 'creates customer traffic data by destination' do
      expect { subject }.to change { Report::CustomerTrafficDataByDestination.count }.by(1)
      report = Report::CustomerTrafficDataByDestination.last!
      expect(report).to have_attributes(calls_count: 3)
    end

    it 'creates customer traffic data full' do
      expect { subject }.to change { Report::CustomerTrafficDataFull.count }.by(1)
      report = Report::CustomerTrafficDataFull.last!
      expect(report).to have_attributes(calls_count: 3)
    end

    it 'creates correct email logs' do
      expect { subject }.to change { ::Log::EmailLog.count }.by(2)
      email_log_1 = ::Log::EmailLog.find_by!(contact_id: contacts.first.id)
      expect(email_log_1).to have_attributes(
                               smtp_connection_id: contacts.first.smtp_connection.id,
                               msg: include('2019-02-15 00:00:00')
                             )
      email_log_2 = ::Log::EmailLog.find_by!(contact_id: contacts.second.id)
      expect(email_log_2).to have_attributes(
                               smtp_connection_id: contacts.second.smtp_connection.id,
                               msg: include('2019-02-15 00:00:00')
                             )
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
