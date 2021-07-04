# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Gateway, :js do
  include_context :login_as_admin
  let!(:_gateways) { FactoryBot.create_list :gateway, 3 }
  let(:pg_max_smallint) { ApplicationRecord::PG_MAX_SMALLINT }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }

  before do
    visit gateways_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  let(:assign_params) do
    {
      enabled: false,
      priority: '1',
      weight: '12',
      is_shared: false,
      acd_limit: '1',
      asr_limit: '1',
      short_calls_limit: '1'
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :enabled
      check :Enabled
      select_by_value assign_params[:enabled], from: :enabled
    end

    if assign_params.key? :priority
      check :Priority
      fill_in :priority, with: assign_params[:priority]
    end

    if assign_params.key? :weight
      check :Weight
      fill_in :weight, with: assign_params[:weight]
    end

    if assign_params.key? :is_shared
      check :Is_shared
      select_by_value assign_params[:is_shared], from: :is_shared
    end

    if assign_params.key? :acd_limit
      check :Acd_limit
      fill_in :acd_limit, with: assign_params[:acd_limit]
    end

    if assign_params.key? :asr_limit
      check :Asr_limit
      fill_in :asr_limit, with: assign_params[:asr_limit]
    end

    if assign_params.key? :short_calls_limit
      check :Short_calls_limit
      fill_in :short_calls_limit, with: assign_params[:short_calls_limit]
    end
  end

  context 'check validates' do
    context 'when :priority have wrong float value' do
      let(:assign_params) { { priority: '0' } }

      it 'should have error: must be greater than zero' do
        subject
        expect(page).to have_selector '.flash', text: 'must be greater than 0'
      end
    end

    context 'when all fields filled with valid values' do
      it 'should pass validations' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, assign_params, be_present
      end
    end
  end
end
