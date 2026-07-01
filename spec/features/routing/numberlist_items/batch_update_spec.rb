# frozen_string_literal: true

RSpec.describe BatchUpdateForm::NumberlistItem, :js do
  include_context :login_as_admin

  let!(:_numberlist_items) { create_list :numberlist_item, 3 }
  let(:success_message) { I18n.t('flash.actions.batch_actions.batch_update.job_scheduled') }
  let!(:lua_script) { create :lua_script }

  before do
    visit routing_numberlist_items_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:assign_params) do
    {
      number_min_length: '3',
      number_max_length: '12',
      action_id: Routing::NumberlistItem::ACTION_ACCEPT.to_s,
      src_rewrite_rule: '^100',
      src_rewrite_result: '200',
      defer_src_rewrite: 'true',
      dst_rewrite_rule: '^300',
      dst_rewrite_result: '400',
      defer_dst_rewrite: 'false',
      lua_script_id: lua_script.id.to_s
    }
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  let(:fill_batch_form) do
    if assign_params.key? :number_min_length
      check :Number_min_length
      fill_in :number_min_length, with: assign_params[:number_min_length]
    end

    if assign_params.key? :number_max_length
      check :Number_max_length
      fill_in :number_max_length, with: assign_params[:number_max_length]
    end

    if assign_params.key? :action_id
      check :Action_id
      select_by_value assign_params[:action_id], from: :action_id
    end

    if assign_params.key? :src_rewrite_rule
      check :Src_rewrite_rule
      fill_in :src_rewrite_rule, with: assign_params[:src_rewrite_rule]
    end

    if assign_params.key? :src_rewrite_result
      check :Src_rewrite_result
      fill_in :src_rewrite_result, with: assign_params[:src_rewrite_result]
    end

    if assign_params.key? :defer_src_rewrite
      check :Defer_src_rewrite
      select_by_value assign_params[:defer_src_rewrite], from: :defer_src_rewrite
    end

    if assign_params.key? :dst_rewrite_rule
      check :Dst_rewrite_rule
      fill_in :dst_rewrite_rule, with: assign_params[:dst_rewrite_rule]
    end

    if assign_params.key? :dst_rewrite_result
      check :Dst_rewrite_result
      fill_in :dst_rewrite_result, with: assign_params[:dst_rewrite_result]
    end

    if assign_params.key? :defer_dst_rewrite
      check :Defer_dst_rewrite
      select_by_value assign_params[:defer_dst_rewrite], from: :defer_dst_rewrite
    end

    if assign_params.key? :lua_script_id
      check :Lua_script_id
      select_by_value assign_params[:lua_script_id], from: :lua_script_id
    end
  end

  context 'when all fields filled with valid values' do
    it 'schedules async batch update job' do
      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::NumberlistItem', be_present, assign_params, be_present
    end
  end
end
