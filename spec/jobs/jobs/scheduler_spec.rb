# frozen_string_literal: true

RSpec.describe Jobs::Scheduler, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  let!(:scheduler) { create(:scheduler, timezone: 'UTC', enabled: true, use_reject_calls: scheduler_use_reject_calls) }

  let!(:objects_enabled) { false }
  let!(:objects_rejects) { true }
  let!(:scheduler_use_reject_calls) { true }

  let!(:customers_auth) { create(:customers_auth, enabled: objects_enabled, reject_calls: objects_rejects, scheduler_id: scheduler.id) }
  let!(:destination) { create(:destination, enabled: objects_enabled, reject_calls: objects_rejects, scheduler_id: scheduler.id) }
  let!(:dialpeer) { create(:dialpeer, enabled: objects_enabled, scheduler_id: scheduler.id) }
  let!(:gateway) { create(:gateway, enabled: objects_enabled, scheduler_id: scheduler.id) }

  it 'Unblocking' do
    expect {
      subject
      customers_auth.reload
      destination.reload
      dialpeer.reload
      gateway.reload
    }.to change { customers_auth.enabled }.from(false).to(true)
                                          .and change { customers_auth.reject_calls }.from(true).to(false)
                                                                                     .and change { destination.enabled }.from(false).to(true)
                                                                                                                        .and change { destination.reject_calls }.from(true).to(false)
                                                                                                                                                                .and change { dialpeer.enabled }.from(false).to(true)
                                                                                                                                                                                                .and change { gateway.enabled }.from(false).to(true)
  end

  context 'blocking by disabling' do
    let!(:objects_enabled) { true }
    let!(:scheduler_use_reject_calls) { false }

    # we should have ranges to force scheduler to block something
    let!(:scheduler_ranges) {
      create(:scheduler_range, scheduler_id: scheduler.id)
    }

    it 'blocking' do
      expect {
        subject
        customers_auth.reload
        destination.reload
        dialpeer.reload
        gateway.reload
      }.to change { customers_auth.enabled }.from(true).to(false)
                                            .and change { destination.enabled }.from(true).to(false)
                                                                               .and change { dialpeer.enabled }.from(true).to(false)
                                                                                                               .and change { gateway.enabled }.from(true).to(false)
    end
  end

  context 'blocking by reject' do
    let!(:objects_enabled) { true }
    let!(:objects_rejects) { false }
    let!(:scheduler_use_reject_calls) { true }

    # we should have ranges to force scheduler to block something
    let!(:scheduler_ranges) {
      create(:scheduler_range, scheduler_id: scheduler.id)
    }

    it 'blocking' do
      expect {
        subject
        customers_auth.reload
        destination.reload
        dialpeer.reload
        gateway.reload
      }.to change { customers_auth.reject_calls }.from(false).to(true)
                                                 .and change { destination.reject_calls }.from(false).to(true)
                                                                                         .and change { dialpeer.enabled }.from(true).to(false)
                                                                                                                         .and change { gateway.enabled }.from(true).to(false)
    end
  end
end
