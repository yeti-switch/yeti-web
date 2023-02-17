# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelist Item actions', bullet: [:n], js: true do
  include_context :login_as_admin

  subject do
    visit rate_management_pricelist_pricelist_items_path(pricelist)
    action!
  end

  let(:pricelist) { FactoryBot.create(:rate_management_pricelist, state, :with_project) }
  let(:state) { :new }
  let!(:pricelist_items) do
    FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelist)
  end

  context 'detect dialpeers' do
    let(:action!) { click_on 'Detect Dialpeers' }

    it 'should be run worker' do
      expect(RateManagement::EnqueueDetectDialpeers).to receive(:call).with(pricelist: pricelist).once.and_call_original
      subject
      expect(page).to have_current_path(rate_management_pricelist_pricelist_items_path(pricelist))
      expect(page).to have_flash_message('Process of detect dialpeers started. Wait few minutes!', type: :notice)
    end

    context 'when RateManagement::RedetectDialpeers return error' do
      let(:error) { RateManagement::EnqueueDetectDialpeers::Error.new('some_error') }

      before do
        allow(RateManagement::EnqueueDetectDialpeers).to receive(:call).with(pricelist: pricelist).and_raise(error)
      end

      it 'should be render error message' do
        subject
        expect(page).to have_current_path(rate_management_pricelist_pricelist_items_path(pricelist))
        expect(page).to have_flash_message(error.message, type: :error)
      end
    end
  end

  context 'redetect dialpeers' do
    let(:action!) { click_on 'Redetect Dialpeers' }
    let(:state) { :dialpeers_detected }

    it 'should be call service' do
      expect(RateManagement::EnqueueRedetectDialpeers).to receive(:call).with(pricelist: pricelist).and_call_original
      subject
      expect(page).to have_current_path(rate_management_pricelist_pricelist_items_path(pricelist))
      expect(page).to have_flash_message('Process of redetect dialpeers started. Wait few minutes!', type: :notice)
    end

    context 'when RateManagement::EnqueueRedetectDialpeers return error' do
      let(:error) { RateManagement::EnqueueRedetectDialpeers::Error.new('some_error') }

      before do
        allow(RateManagement::EnqueueRedetectDialpeers).to receive(:call).with(pricelist: pricelist).and_raise(error)
      end

      it 'should be render error message' do
        subject
        expect(page).to have_current_path(rate_management_pricelist_pricelist_items_path(pricelist))
        expect(page).to have_flash_message(error.message, type: :error)
      end
    end
  end

  context 'apply changes' do
    let(:action!) do
      accept_confirm do
        click_on 'Apply Changes'
      end
    end

    let(:state) { :dialpeers_detected }

    it 'should be call service' do
      expect(RateManagement::EnqueueApplyChanges).to receive(:call).with(pricelist: pricelist).and_call_original

      expect do
        subject
        expect(page).to have_current_path(rate_management_pricelist_pricelist_items_path(pricelist))
      end.to have_enqueued_job(Worker::RateManagementApplyChanges).on_queue('rate_management').with(pricelist.id)

      expect(page).to have_flash_message('Process of apply changes started. Wait few minutes!', type: :notice)
    end

    context 'when pricelist has error type items' do
      before do
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, detected_dialpeer_ids: [1, 2])
      end

      let(:action!) { nil }

      it 'should not present "Apply Changes" action' do
        subject

        expect(page).not_to have_action_item('Apply Changes')
      end
    end

    context 'when RateManagement::EnqueueRedetectDialpeers return error' do
      let(:error) { RateManagement::EnqueueApplyChanges::Error.new('some_error') }

      before do
        allow(RateManagement::EnqueueApplyChanges).to receive(:call).with(pricelist: pricelist).and_raise(error)
      end

      it 'should be render error message' do
        subject
        expect(page).to have_current_path(rate_management_pricelist_pricelist_items_path(pricelist))
        expect(page).to have_flash_message(error.message, type: :error)
      end
    end
  end

  context 'edit pricelist' do
    let(:action!) { click_on 'Edit Pricelist' }

    it 'should redirect to correct path' do
      subject

      expect(page).to have_current_path(edit_rate_management_pricelist_path(pricelist))
    end
  end

  context 'delete pricelist' do
    let(:action!) do
      accept_confirm do
        click_on 'Delete Pricelist'
      end
    end

    it 'should destroy pricelist with items' do
      expect do
        subject
        expect(page).to have_flash_message('Pricelist was successfully destroyed.', type: :notice)
      end.to change {
        RateManagement::Pricelist.count
      }.by(-1)
        .and change {
               RateManagement::PricelistItem.count
             }.by(-pricelist_items.size)
    end
  end
end
