# frozen_string_literal: true

RSpec.describe BatchUpdateForm::NumberList, :js do
  include_context :login_as_admin
  let!(:_numberlists) { create_list :numberlist, 3 }
  let(:success_message) { I18n.t('flash.actions.batch_actions.batch_update.job_scheduled') }
  let!(:mode) { Routing::NumberlistMode.take! }
  let!(:default_action) { Routing::NumberlistAction.take! }
  let!(:lua_script) { create :lua_script }
  before do
    visit numberlists_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    let(:changes) { { mode_id: mode.id.to_s } }
    context '"mode_id"' do
      it 'should change value lonely' do
        check :Mode_id
        select mode.name, from: :mode_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
      end
    end

    context '"default_action_id"' do
      let(:changes) { { default_action_id: default_action.id.to_s } }
      it 'should change value lonely' do
        check :Default_action_id
        select default_action.name, from: :default_action_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
      end
    end

    context '"default_src_rewrite_rule"' do
      let(:changes) { { default_src_rewrite_rule: 'string' } }
      it 'should change value lonely' do
        check :Default_src_rewrite_rule
        fill_in :default_src_rewrite_rule, with: changes[:default_src_rewrite_rule]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
      end
    end

    context '"default_src_rewrite_result"' do
      let(:changes) { { default_src_rewrite_result: 'string' } }
      it 'should change value lonely' do
        check :Default_src_rewrite_result
        fill_in :default_src_rewrite_result, with: changes[:default_src_rewrite_result]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
      end
    end

    context '"default_dst_rewrite_rule"' do
      let(:changes) { { default_dst_rewrite_rule: 'string' } }
      it 'should change value lonely' do
        check :Default_dst_rewrite_rule
        fill_in :default_dst_rewrite_rule, with: changes[:default_dst_rewrite_rule]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
      end
    end

    context '"default_dst_rewrite_result"' do
      let(:changes) { { default_dst_rewrite_result: 'string' } }
      it 'should change value lonely' do
        check :Default_dst_rewrite_result
        fill_in :default_dst_rewrite_result, with: changes[:default_dst_rewrite_result]
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
      end
    end

    context '"lua_script_id"' do
      let(:changes) { { lua_script_id: lua_script.id.to_s } }
      it 'should change value lonely' do
        check :Lua_script_id
        select lua_script.name, from: :lua_script_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
      end
    end

    it 'all fields should have success' do
      changes = {
        mode_id: mode.id.to_s,
        default_action_id: default_action.id.to_s,
        default_src_rewrite_rule: 'string',
        default_src_rewrite_result: 'string',
        default_dst_rewrite_rule: 'string',
        default_dst_rewrite_result: 'string',
        lua_script_id: lua_script.id.to_s
      }
      check :Mode_id
      select mode.name, from: :mode_id

      check :Default_action_id
      select default_action.name, from: :default_action_id

      check :Default_src_rewrite_rule
      fill_in :default_src_rewrite_rule, with: changes[:default_src_rewrite_rule]

      check :Default_src_rewrite_result
      fill_in :default_src_rewrite_result, with: changes[:default_src_rewrite_result]

      check :Default_dst_rewrite_rule
      fill_in :default_dst_rewrite_rule, with: changes[:default_dst_rewrite_rule]

      check :Default_dst_rewrite_result
      fill_in :default_dst_rewrite_result, with: changes[:default_dst_rewrite_result]

      check :Lua_script_id
      select lua_script.name, from: :lua_script_id

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::Numberlist', be_present, changes, be_present
    end
  end
end
