# frozen_string_literal: true

RSpec.describe CustomCdrReport::GenerateData do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) do
    {
      report: report
    }
  end

  let!(:smtp_connection) { FactoryBot.create(:smtp_connection) }
  let!(:customer) do
    FactoryBot.create(:customer)
  end
  let!(:report) do
    FactoryBot.create(:custom_cdr, report_attrs)
  end
  let(:report_attrs) do
    {
      date_start: Time.parse('2019-02-15'),
      date_end: Time.parse('2019-02-16'),
      group_by: %w[customer_id]
    }
  end

  before do
    Cdr::Cdr.add_partition_for Time.parse('2019-02-14')
    Cdr::Cdr.add_partition_for Time.parse('2019-02-15')
    Cdr::Cdr.add_partition_for Time.parse('2019-02-16')

    # not included CDR
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-14 23:59:59'))
    FactoryBot.create(:cdr, time_start: Time.parse('2019-02-16 00:00:00'))
  end

  let!(:cdrs) do
    [
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer: customer),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer: customer),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), customer: customer)
    ]
  end

  it 'creates custom data' do
    expect { subject }.to change { Report::CustomData.count }.by(1)
    report = Report::CustomData.last!
    expect(report).to have_attributes(agg_calls_count: 3)
  end

  it 'does not create email log' do
    expect { subject }.to change { ::Log::EmailLog.count }.by(0)
  end

  context 'when CDRs belongs to different customers' do
    let!(:customer2) do
      FactoryBot.create(:customer)
    end
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer: customer2),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer: customer),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), customer: customer)
      ]
    end

    it 'creates custom data' do
      expect { subject }.to change { Report::CustomData.count }.by(2)
      expect(
        Report::CustomData.where(customer_id: customer2.id, agg_calls_count: 1).count
      ).to eq 1
      expect(
        Report::CustomData.where(customer_id: customer.id, agg_calls_count: 2).count
      ).to eq 1
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

    it 'creates custom data' do
      expect { subject }.to change { Report::CustomData.count }.by(1)
      report = Report::CustomData.last!
      expect(report).to have_attributes(agg_calls_count: 3)
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

  context 'when report has customer' do
    let(:report_attrs) do
      super().merge customer: customer
    end

    before do
      # not included CDR
      customer2 = FactoryBot.create(:customer)
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer: customer2)
    end

    it 'creates custom data' do
      expect { subject }.to change { Report::CustomData.count }.by(1)
      report = Report::CustomData.last!
      expect(report).to have_attributes(agg_calls_count: 3)
    end
  end

  context 'when report has filter' do
    let(:report_attrs) do
      super().merge filter: 'duration > 0'
    end
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer: customer, duration: 1),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer: customer, duration: 10),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), customer: customer, duration: 100)
      ]
    end

    before do
      # not included CDR
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer: customer, duration: 0)
    end

    it 'creates custom data' do
      expect { subject }.to change { Report::CustomData.count }.by(1)
      report = Report::CustomData.last!
      expect(report).to have_attributes(agg_calls_count: 3)
    end
  end

  context 'when report already completed' do
    let(:report_attrs) do
      super().merge completed: true
    end

    it 'does not create custom data' do
      expect { safe_subject }.to change { Report::CustomData.count }.by(0)
    end

    include_examples :raises_exception, CustomCdrReport::GenerateData::Error
  end
end
