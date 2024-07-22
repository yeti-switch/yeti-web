# frozen_string_literal: true

RSpec.describe Jobs::ServiceRenew, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }
  before do
    create(:service, renew_period_id: nil, renew_at: 1.day.ago)
    create(:service, renew_period_id: Billing::Service::RENEW_PERIOD_ID_DAY, renew_at: nil)
    create(:service, renew_period_id: Billing::Service::RENEW_PERIOD_ID_DAY, renew_at: 1.minute.from_now)
    create(:service, renew_period_id: Billing::Service::RENEW_PERIOD_ID_MONTH, renew_at: 1.day.from_now)
  end

  let!(:services_for_renew) do
    [
      create(:service, renew_period_id: Billing::Service::RENEW_PERIOD_ID_DAY, renew_at: 1.second.ago),
      create(:service, renew_period_id: Billing::Service::RENEW_PERIOD_ID_MONTH, renew_at: 1.day.ago),
      create(:service, renew_period_id: Billing::Service::RENEW_PERIOD_ID_MONTH, renew_at: 1.month.ago)
    ]
  end

  it 'renews correct services' do
    services_for_renew.each do |service|
      expect(Billing::Service::Renew).to receive(:perform).with(service).once
    end
    subject
  end

  context 'when renew raises an error' do
    it 'renews all ready services' do
      expect(Billing::Service::Renew).to receive(:perform).with(services_for_renew[0]).once.and_raise(StandardError, 'test0')
      expect(Billing::Service::Renew).to receive(:perform).with(services_for_renew[1]).once
      expect(Billing::Service::Renew).to receive(:perform).with(services_for_renew[2]).once.and_raise(StandardError, 'test2')

      expect(CaptureError).to receive(:capture).with(
        a_kind_of(StandardError),
        hash_including(extra: { service_id: services_for_renew[0].id })
      ).once
      expect(CaptureError).to receive(:capture).with(
        a_kind_of(StandardError),
        hash_including(extra: { service_id: services_for_renew[2].id })
      ).once

      subject
    end
  end
end
