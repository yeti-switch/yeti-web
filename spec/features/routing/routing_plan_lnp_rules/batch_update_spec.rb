# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlanLnpRule, :js do
  include_context :login_as_admin
  let!(:_lnp_routing_plan_lnp_rules) { create_list :lnp_routing_plan_lnp_rule, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:database) { create :lnp_database, :thinq }
  let!(:routing_plan) { create :routing_plan }
  before do
    visit lnp_routing_plan_lnp_rules_path
    click_button 'Update batch'
  end

  subject { click_button :OK }

  context 'should check validates for the field:' do
    context '"routing_plan_id"' do
      let(:changes) { { routing_plan_id: routing_plan.id.to_s } }
      it 'should change value lonely' do
        check :Routing_plan_id
        select routing_plan.name, from: :routing_plan_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
      end
    end

    context '"routing_plan_id"' do
      let(:changes) { { routing_plan_id: routing_plan.id.to_s } }
      it 'should change value lonely' do
        check :Routing_plan_id
        select routing_plan.name, from: :routing_plan_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
      end
    end

    context '"req_dst_rewrite_rule"' do
      context 'should have success' do
        it 'with blank value' do
          changes = { req_dst_rewrite_rule: '' }
          check :Req_dst_rewrite_rule
          fill_in :req_dst_rewrite_rule, with: changes[:req_dst_rewrite_rule]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { req_dst_rewrite_rule: 'string' }
          check :Req_dst_rewrite_rule
          fill_in :req_dst_rewrite_rule, with: changes[:req_dst_rewrite_rule]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end
      end
    end

    context '"req_dst_rewrite_result"' do
      before { check :Req_dst_rewrite_result }
      context 'should have success' do
        it 'with blank value' do
          changes = { req_dst_rewrite_result: '' }
          fill_in :req_dst_rewrite_result, with: changes[:req_dst_rewrite_result]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { req_dst_rewrite_result: 'string' }
          fill_in :req_dst_rewrite_result, with: changes[:req_dst_rewrite_result]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end
      end
    end

    context '"lrn_rewrite_rule"' do
      before { check :Lrn_rewrite_rule }
      context 'should have success' do
        it 'with blank value' do
          changes = { lrn_rewrite_rule: '' }
          fill_in :lrn_rewrite_rule, with: changes[:lrn_rewrite_rule]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { lrn_rewrite_rule: 'string' }
          fill_in :lrn_rewrite_rule, with: changes[:lrn_rewrite_rule]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end
      end
    end

    context '"lrn_rewrite_result"' do
      before { check :Lrn_rewrite_result }
      context 'should have success' do
        changes = { lrn_rewrite_result: '' }
        it 'with blank value' do
          fill_in :lrn_rewrite_result, with: changes[:lrn_rewrite_result]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end

        it 'change value lonely' do
          changes = { lrn_rewrite_result: 'string' }
          fill_in :lrn_rewrite_result, with: changes[:lrn_rewrite_result]
          expect do
            subject
            expect(page).to have_selector '.flash', text: success_message
          end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
        end
      end
    end

    context '"database_id"' do
      let(:changes) { { database_id: database.id.to_s } }
      it 'should change value lonely' do
        check :Database_id
        select database.name, from: :database_id
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
      end
    end

    it 'all fields should have success and pass validates' do
      changes = {
        routing_plan_id: routing_plan.id.to_s,
        req_dst_rewrite_rule: 'string 123',
        req_dst_rewrite_result: 'string 123',
        database_id: database.id.to_s,
        lrn_rewrite_rule: 'string 123',
        lrn_rewrite_result: 'string 123'
      }
      check :Routing_plan_id
      select routing_plan.name, from: :routing_plan_id

      check :Req_dst_rewrite_rule
      fill_in :req_dst_rewrite_rule, with: 'string 123'

      check :Req_dst_rewrite_result
      fill_in :req_dst_rewrite_result, with: 'string 123'

      check :Database_id
      select database.name, from: :database_id

      check :Lrn_rewrite_rule
      fill_in :lrn_rewrite_rule, with: 'string 123'

      check :Lrn_rewrite_result
      fill_in :lrn_rewrite_result, with: 'string 123'

      expect do
        subject
        expect(page).to have_selector '.flash', text: success_message
      end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, changes, be_present
    end
  end
end
