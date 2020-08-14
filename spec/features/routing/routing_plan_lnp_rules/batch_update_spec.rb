# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlanLnpRule, :js do
  include_context :login_as_admin
  let!(:_lnp_routing_plan_lnp_rules) { FactoryBot.create_list :lnp_routing_plan_lnp_rule, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:database) { FactoryBot.create :lnp_database, :thinq }
  let!(:routing_plan) { FactoryBot.create :routing_plan }

  before do
    visit lnp_routing_plan_lnp_rules_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end
  let(:assign_params) do
    {
      routing_plan_id: routing_plan.id.to_s,
      req_dst_rewrite_rule: 'string 123',
      req_dst_rewrite_result: 'string 123',
      database_id: database.id.to_s,
      lrn_rewrite_rule: 'string 123',
      lrn_rewrite_result: 'string 123'
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :routing_plan_id
      check :Routing_plan_id
      select_by_value assign_params[:routing_plan_id], from: :routing_plan_id
    end

    if assign_params.key? :req_dst_rewrite_rule
      check :Req_dst_rewrite_rule
      fill_in :req_dst_rewrite_rule, with: assign_params[:req_dst_rewrite_rule]
    end

    if assign_params.key? :req_dst_rewrite_result
      check :Req_dst_rewrite_result
      fill_in :req_dst_rewrite_result, with: assign_params[:req_dst_rewrite_result]
    end

    if assign_params.key? :database_id
      check :Database_id
      select_by_value assign_params[:database_id], from: :database_id
    end

    if assign_params.key? :lrn_rewrite_rule
      check :Lrn_rewrite_rule
      fill_in :lrn_rewrite_rule, with: assign_params[:lrn_rewrite_rule]
    end

    if assign_params.key? :lrn_rewrite_result
      check :Lrn_rewrite_result
      fill_in :lrn_rewrite_result, with: assign_params[:lrn_rewrite_result]
    end
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  context 'should check validates for the field:' do
    context 'when change "database_id"' do
      let(:assign_params) { { database_id: database.id.to_s } }
      let(:fill_batch_form) do
        check :Database_id
        select_by_value assign_params[:database_id], from: :database_id
      end

      it 'should have success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, assign_params, be_present
      end
    end

    context 'when all fields filled with valid values' do
      it 'should have success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Lnp::RoutingPlanLnpRule', be_present, assign_params, be_present
      end
    end
  end
end
