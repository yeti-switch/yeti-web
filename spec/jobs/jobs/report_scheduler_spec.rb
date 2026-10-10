# frozen_string_literal: true

RSpec.describe Jobs::ReportScheduler, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }
  let(:period) { Report::SchedulerPeriod.find(1) }
  let(:due_at) { 1.hour.ago }

  def make_due(scheduler)
    scheduler.update_columns(next_run_at: due_at)
    scheduler
  end

  context 'when customer traffic scheduler customer was deleted' do
    let(:valid_customer) { create(:customer) }
    let!(:orphan) do
      make_due(create(:customer_traffic_scheduler, period: period)).tap { |s| s.update_columns(customer_id: 999_999) }
    end
    let!(:valid) { make_due(create(:customer_traffic_scheduler, period: period, customer: valid_customer)) }

    it 'skips the orphan, moves its next run forward and still runs the other schedulers' do
      expect(CreateReport::CustomerTraffic).to receive(:call).once.with(hash_including(customer: valid_customer))

      subject

      expect(orphan.reload.next_run_at).to be > Time.current
      expect(orphan.last_run_at).to be_nil
      expect(valid.reload.next_run_at).to be > Time.current
    end

    it 'does nothing on a second run' do
      allow(CreateReport::CustomerTraffic).to receive(:call)
      subject
      expect(CreateReport::CustomerTraffic).not_to receive(:call)
      described_class.new(double).call
    end
  end

  context 'when customer traffic scheduler contractor is no longer a customer' do
    let(:contractor) { create(:customer, vendor: true) }
    let!(:orphan) { make_due(create(:customer_traffic_scheduler, period: period, customer: contractor)) }

    before { contractor.update_columns(customer: false) }

    it 'skips it without raising' do
      expect(CreateReport::CustomerTraffic).not_to receive(:call)
      expect { subject }.not_to raise_error
      expect(orphan.reload.next_run_at).to be > Time.current
    end
  end

  context 'when vendor traffic scheduler vendor was deleted' do
    let(:valid_vendor) { create(:vendor) }
    let!(:orphan) do
      make_due(create(:vendor_traffic_scheduler, period: period)).tap { |s| s.update_columns(vendor_id: 999_999) }
    end
    let!(:valid) { make_due(create(:vendor_traffic_scheduler, period: period, vendor: valid_vendor)) }

    it 'skips the orphan and still runs the other schedulers' do
      expect(CreateReport::VendorTraffic).to receive(:call).once.with(hash_including(vendor: valid_vendor))

      subject

      expect(orphan.reload.next_run_at).to be > Time.current
      expect(valid.reload.next_run_at).to be > Time.current
    end
  end

  context 'when custom cdr scheduler customer was deleted' do
    let!(:orphan) do
      make_due(create(:custom_cdr_scheduler, :filled, period: period)).tap { |s| s.update_columns(customer_id: 999_999) }
    end
    let!(:without_customer) { make_due(create(:custom_cdr_scheduler, period: period)) }

    it 'skips the orphan instead of reporting on all customers' do
      expect(CreateReport::CustomCdr).to receive(:call).once.with(hash_including(customer: nil))

      subject

      expect(orphan.reload.next_run_at).to be > Time.current
      expect(without_customer.reload.next_run_at).to be > Time.current
    end
  end
end
