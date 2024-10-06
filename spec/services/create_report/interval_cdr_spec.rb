# frozen_string_literal: true

RSpec.describe CreateReport::IntervalCdr do
  subject do
    described_class.call(service_params)
  end

  shared_examples :creates_report do
    it 'creates Report::IntervalCdr' do
      expect { subject }.to change { Report::IntervalCdr.count }.by(1)

      report = Report::IntervalCdr.last!
      expect(report).to have_attributes(expected_report_attrs)
    end

    it 'enqueues Worker::GenerateReportDataJob' do
      expect { subject }.to have_enqueued_job(Worker::GenerateReportDataJob).once.on_queue('report').with do |*args|
        report = Report::IntervalCdr.last!
        expect(args).to eq ['IntervalCdr', report.id]
      end
    end
  end

  shared_examples :does_not_create_report do
    it 'does not create Report::IntervalCdr' do
      expect { safe_subject }.to change { Report::IntervalCdr.count }.by(0)
    end

    it "raises #{described_class}::Error" do
      expect { subject }.to raise_error(described_class::Error)
    end

    it 'does not enqueue Worker::GenerateReportDataJob' do
      safe_subject
      expect { safe_subject }.not_to have_enqueued_job(Worker::GenerateReportDataJob)
    end
  end

  let!(:aggregation_function) do
    Report::IntervalAggregator.take!
  end

  let(:service_params) do
    {
      date_start: 2.days.ago,
      date_end: 1.day.ago,
      filter: nil,
      group_by: %w[customer_id],
      send_to: nil,
      aggregation_function: aggregation_function,
      aggregate_by: 'dialpeer_fee',
      interval_length: 60
    }
  end

  let(:expected_report_attrs) do
    {
      completed: false,
      date_start: be_within(0.1).of(service_params[:date_start]),
      date_end: be_within(0.1).of(service_params[:date_end]),
      filter: service_params[:filter],
      group_by: service_params[:group_by],
      send_to: service_params[:send_to],
      aggregator_id: service_params[:aggregation_function].id,
      aggregate_by: service_params[:aggregate_by],
      interval_length: service_params[:interval_length]
    }
  end

  include_examples :creates_report

  context 'with multiple group_by' do
    let(:service_params) do
      super().merge group_by: %w[customer_id success]
    end
    let(:expected_report_attrs) do
      super().merge group_by: %w[customer_id success]
    end

    include_examples :creates_report
  end

  context 'with group_by=[]' do
    let(:service_params) do
      super().merge group_by: []
    end
    let(:expected_report_attrs) do
      super().merge group_by: []
    end

    include_examples :creates_report
  end

  context 'with filled filter' do
    let(:service_params) do
      super().merge filter: 'node_id = 123'
    end
    let(:expected_report_attrs) do
      super().merge filter: 'node_id = 123'
    end

    include_examples :creates_report
  end

  context 'with filter=""' do
    let(:service_params) do
      super().merge filter: ''
    end
    let(:expected_report_attrs) do
      super().merge filter: nil
    end

    include_examples :creates_report
  end

  context 'with filled send_to' do
    let!(:contacts) do
      FactoryBot.create_list(:contact, 3, :filled)
    end
    let(:service_params) do
      super().merge send_to: [contacts.first.id, contacts.second.id]
    end
    let(:expected_report_attrs) do
      super().merge send_to: [contacts.first.id, contacts.second.id]
    end

    include_examples :creates_report
  end

  context 'with send_to=[]' do
    let(:service_params) do
      super().merge send_to: []
    end
    let(:expected_report_attrs) do
      super().merge send_to: nil
    end

    include_examples :creates_report
  end

  context 'with date_start=null' do
    let(:service_params) do
      super().merge date_start: nil
    end

    include_examples :does_not_create_report
  end

  context 'with date_end=null' do
    let(:service_params) do
      super().merge date_end: nil
    end

    include_examples :does_not_create_report
  end

  context 'with invalid group_by' do
    let(:service_params) do
      super().merge group_by: %w[test]
    end

    include_examples :does_not_create_report
  end

  context 'with invalid send_to' do
    let(:service_params) do
      super().merge send_to: [999_999]
    end

    include_examples :does_not_create_report
  end

  context 'with aggregation_function=null' do
    let(:service_params) do
      super().merge aggregation_function: nil
    end

    include_examples :does_not_create_report
  end

  context 'with aggregate_by=""' do
    let(:service_params) do
      super().merge aggregate_by: ''
    end

    include_examples :does_not_create_report
  end

  context 'with aggregate_by=null' do
    let(:service_params) do
      super().merge aggregate_by: nil
    end

    include_examples :does_not_create_report
  end
end
