# frozen_string_literal: true

RSpec.describe RateManagement::EnqueueRedetectDialpeers do
  subject { described_class.call(**service_params) }

  let(:service_params) { { pricelist: pricelist } }
  let!(:pricelist) do
    FactoryBot.create(:rate_management_pricelist, :dialpeers_detected, :with_project)
  end

  shared_examples :failed_to_enqueue do |error_message|
    it 'raises RateManagement::EnqueueRedetectDialpeers' do
      expect { subject }.to raise_error(RateManagement::EnqueueRedetectDialpeers::Error, error_message)
    end

    it 'does not enqueue Worker::RateManagementRedetectDialpeers' do
      expect { safe_subject }.not_to have_enqueued_job(Worker::RateManagementRedetectDialpeers)
    end

    it 'does not change pricelist.detect_dialpeers_in_progress' do
      expect { safe_subject }.not_to change { pricelist.reload.detect_dialpeers_in_progress }
    end
  end

  it 'enqueues Worker::RateManagementRedetectDialpeers' do
    expect { subject }.to have_enqueued_job(Worker::RateManagementRedetectDialpeers)
      .on_queue('rate_management')
      .with(pricelist.id)

    expect(pricelist.reload).to have_attributes(
                                  detect_dialpeers_in_progress: true
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
      FactoryBot.create(
        :rate_management_pricelist,
        :dialpeers_detected,
        :with_project,
        detect_dialpeers_in_progress: true
      )
    end

    include_examples :failed_to_enqueue, 'Dialpeers detection already in progress'
  end

  context 'when pricelist.apply_changes_in_progress=true' do
    let(:pricelist) do
      FactoryBot.create(
        :rate_management_pricelist,
        :dialpeers_detected,
        :with_project,
        apply_changes_in_progress: true
      )
    end

    include_examples :failed_to_enqueue, 'Applying changes already in progress'
  end
end
