# frozen_string_literal: true

RSpec.describe BatchUpdateForm::NumberList, :js do
  include_context :login_as_admin
  let!(:_numberlists) { FactoryBot.create_list :numberlist, 3 }
  let(:success_message) { I18n.t('flash.actions.batch_actions.batch_update.job_scheduled') }
  let!(:mode_id) { Routing::Numberlist::MODE_STRICT }
  let!(:default_action_id) { Routing::Numberlist::DEFAULT_ACTION_ACCEPT }
  let!(:lua_script) { FactoryBot.create :lua_script }

  before do
    visit numberlists_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  let(:assign_params) do
    {
      mode_id: mode.id.to_s,
      default_action_id: default_action.id.to_s,
      default_src_rewrite_rule: 'string',
      default_src_rewrite_result: 'string',
      default_dst_rewrite_rule: 'string',
      default_dst_rewrite_result: 'string',
      lua_script_id: lua_script.id.to_s
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :mode_id
      check :Mode_id
      select_by_value assign_params[:mode_id], from: :mode_id
    end

    if assign_params.key? :default_action_id
      check :Default_action_id
      select_by_value assign_params[:default_action_id], from: :default_action_id
    end

    if assign_params.key? :default_src_rewrite_rule
      check :Default_src_rewrite_rule
      fill_in :default_src_rewrite_rule, with: assign_params[:default_src_rewrite_rule]
    end

    if assign_params.key? :default_src_rewrite_result
      check :Default_src_rewrite_result
      fill_in :default_src_rewrite_result, with: assign_params[:default_src_rewrite_result]
    end

    if assign_params.key? :default_dst_rewrite_rule
      check :Default_dst_rewrite_rule
      fill_in :default_dst_rewrite_rule, with: assign_params[:default_dst_rewrite_rule]
    end

    if assign_params.key? :default_dst_rewrite_result
      check :Default_dst_rewrite_result
      fill_in :default_dst_rewrite_result, with: assign_params[:default_dst_rewrite_result]
    end

    if assign_params.key? :lua_script_id
      check :Lua_script_id
      select_by_value assign_params[:lua_script_id], from: :lua_script_id
    end
  end

  context 'should check validates' do
    context 'when :mode_id changed' do
      let(:assign_params) { { mode_id: mode.id.to_s } }

      it 'should pass validations with success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, assign_params, be_present
      end
    end

    context 'when all fields filed with valid values' do
      it 'should pass validations with success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, assign_params, be_present
      end
    end
  end
end
