# frozen_string_literal: true

RSpec.describe Jobs::ReportScheduler, '#call' do
  subject do
    job.call
  end

  let(:job) do
    described_class.new(double)
  end

  context 'when no schedulers exists' do
    it 'does nothing' do
      expect(CreateReport::CustomerTraffic).not_to receive(:call)
      expect(CreateReport::CustomCdr).not_to receive(:call)
      expect(CreateReport::IntervalCdr).not_to receive(:call)
      expect(CreateReport::VendorTraffic).not_to receive(:call)
      subject
    end
  end

  context 'when vendor_traffic_schedulers exists' do
    let!(:vendor_traffic_schedulers) do
      FactoryBot.create_list(:vendor_traffic_scheduler, 2, next_run_at: Time.current)
    end

    it 'creates reports' do
      expect(CreateReport::VendorTraffic).to receive(:call).with
    end
  end
end
