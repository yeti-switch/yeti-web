# frozen_string_literal: true

RSpec.describe RateManagement::EnqueueApplyChanges do
  subject { described_class.call(**service_params) }

  let(:service_params) { { pricelist: pricelist } }
  let!(:pricelist) do
    FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, :with_project)
  end

  shared_examples :failed_to_enqueue do |error_message|
    it 'raises RateManagement::EnqueueDetectDialpeers' do
      expect { subject }.to raise_error(RateManagement::EnqueueApplyChanges::Error, error_message)
    end

    it 'does not enqueue Worker::RateManagementDetectDialpeers' do
      expect { safe_subject }.not_to have_enqueued_job(Worker::RateManagementApplyChanges)
    end

    it 'does not change pricelist.detect_dialpeers_in_progress' do
      expect { safe_subject }.not_to change { pricelist.reload.apply_changes_in_progress }
    end
  end

  it 'enqueues Worker::RateManagementDetectDialpeers' do
    expect { subject }.to have_enqueued_job(Worker::RateManagementApplyChanges)
      .on_queue('rate_management')
      .with(pricelist.id)

    expect(pricelist.reload).to have_attributes(
                                  apply_changes_in_progress: true
                                )
  end

  context 'when pricelist is in New state' do
    let(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :new, :with_project)
    end

    include_examples :failed_to_enqueue, 'Pricelist must be in Dialpeers detected state'
  end

  context 'when pricelist is in Applied state' do
    let(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :applied, :with_project)
    end

    include_examples :failed_to_enqueue, 'Pricelist must be in Dialpeers detected state'
  end

  context 'when pricelist.detect_dialpeers_in_progress=true' do
    let(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, :with_project, detect_dialpeers_in_progress: true)
    end

    include_examples :failed_to_enqueue, 'Dialpeers detection already in progress'
  end

  context 'when pricelist.apply_changes_in_progress=true' do
    let(:pricelist) do
      FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, :with_project, apply_changes_in_progress: true)
    end

    include_examples :failed_to_enqueue, 'Applying changes already in progress'
  end

  context 'when pricelist.valid_till is in the past' do
    let(:pricelist) do
      FactoryBot.create(
        :rate_management_pricelist,
        :dialpeers_detected,
        :with_project,
        valid_from: 2.days.from_now,
        valid_till: 1.second.ago
      )
    end

    include_examples :failed_to_enqueue, 'Pricelist valid_till must be in the future'
  end
end
