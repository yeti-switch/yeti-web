# frozen_string_literal: true

RSpec.describe GenerateReportData::IntervalCdr do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) do
    {
      report: report
    }
  end
  let!(:smtp_connection) { FactoryBot.create(:smtp_connection) }
  let!(:report) do
    FactoryBot.create(:interval_cdr, report_attrs)
  end
  let!(:aggregation_function) do
    Report::IntervalAggregator.find_by!(name: 'Sum')
  end
  let(:report_attrs) do
    {
      date_start: Time.parse('2019-02-15'),
      date_end: Time.parse('2019-02-16'),
      aggregation_function: aggregation_function,
      interval_length: 1440, # 24 hours
      aggregate_by: 'customer_price',
      group_by: nil,
      filter: nil
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
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer_price: 5),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 07:59:59'), customer_price: 50),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer_price: 200),
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), customer_price: 500)
    ]
  end

  it 'creates interval data' do
    expect { subject }.to change { Report::IntervalData.count }.by(1)
    report = Report::IntervalData.last!
    expect(report).to have_attributes(
                        timestamp: Time.parse('2019-02-15 00:00:00'),
                        aggregated_value: 755
                      )
  end

  it 'does not create email log' do
    expect { subject }.to change { ::Log::EmailLog.count }.by(0)
  end

  context 'with cdrs from multiple intervals' do
    let(:report_attrs) do
      super().merge interval_length: 360 # 6 hours
    end
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer_price: 5),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 05:59:59'), customer_price: 50),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 06:00:00'), customer_price: 200),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:59:59'), customer_price: 500)
      ]
    end

    it 'creates interval data' do
      expect { subject }.to change { Report::IntervalData.count }.by(2)
      reports = Report::IntervalData.all.last(2)
      expect(
        reports.map(&:attributes).map(&:symbolize_keys)
      ).to match_array(
             [
               hash_including(timestamp: Time.parse('2019-02-15 00:00:00'), aggregated_value: 55),
               hash_including(timestamp: Time.parse('2019-02-15 06:00:00'), aggregated_value: 700)
             ]
           )
    end

    it 'does not create email log' do
      expect { subject }.to change { ::Log::EmailLog.count }.by(0)
    end
  end

  context 'with single group_by' do
    let(:report_attrs) do
      super().merge group_by: %w[duration]
    end
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer_price: 5, duration: 1),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 07:59:59'), customer_price: 50, duration: 2),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer_price: 200, duration: 1)
      ]
    end

    it 'creates interval data' do
      expect { subject }.to change { Report::IntervalData.count }.by(2)
      reports = Report::IntervalData.all.last(2)
      expect(reports.map(&:aggregated_value)).to match_array [205, 50]
    end

    it 'does not create email log' do
      expect { subject }.to change { ::Log::EmailLog.count }.by(0)
    end
  end

  context 'with multiple group_by' do
    let(:report_attrs) do
      super().merge group_by: %w[duration is_last_cdr]
    end
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer_price: 5, duration: 1, is_last_cdr: true),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 07:59:59'), customer_price: 50, duration: 2, is_last_cdr: true),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer_price: 200, duration: 1, is_last_cdr: false)
      ]
    end

    it 'creates interval data' do
      expect { subject }.to change { Report::IntervalData.count }.by(3)
      reports = Report::IntervalData.all.last(3)
      expect(reports.map(&:aggregated_value)).to match_array [200, 50, 5]
    end

    it 'does not create email log' do
      expect { subject }.to change { ::Log::EmailLog.count }.by(0)
    end
  end

  context 'when there are no CDRs for date_start - date_end' do
    let!(:cdrs) { nil }

    it 'does not create interval data' do
      expect { subject }.to change { Report::IntervalData.count }.by(0)
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

    it 'creates interval data' do
      expect { subject }.to change { Report::IntervalData.count }.by(1)
      report = Report::IntervalData.last!
      expect(report).to have_attributes(
                          timestamp: Time.parse('2019-02-15 00:00:00'),
                          aggregated_value: 755
                        )
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

  context 'when report has filter' do
    let(:report_attrs) do
      super().merge filter: 'duration > 0'
    end
    let!(:cdrs) do
      [
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 00:00:00'), customer_price: 5, duration: 1),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 07:59:59'), customer_price: 50, duration: 10),
        FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 23:59:59'), customer_price: 200, duration: 100)
      ]
    end

    before do
      # not included CDR
      FactoryBot.create(:cdr, time_start: Time.parse('2019-02-15 11:23:05'), customer_price: 500, duration: 0)
    end

    it 'creates interval data' do
      expect { subject }.to change { Report::IntervalData.count }.by(1)
      report = Report::IntervalData.last!
      expect(report).to have_attributes(
                          timestamp: Time.parse('2019-02-15 00:00:00'),
                          aggregated_value: 255
                        )
    end
  end

  context 'when report already completed' do
    let(:report_attrs) do
      super().merge completed: true
    end

    it 'does not create interval data' do
      expect { safe_subject }.to change { Report::IntervalData.count }.by(0)
    end

    include_examples :raises_exception, GenerateReportData::IntervalCdr::Error
  end
end
