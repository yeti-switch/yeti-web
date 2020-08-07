# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlanStaticRoute, :js do
  include_context :login_as_admin
  let!(:_static_routes) { FactoryBot.create_list :static_route, 3 }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }
  let!(:vendor) { FactoryBot.create :vendor }
  let!(:routing_plan) { FactoryBot.create :routing_plan, :with_static_routes }
  let(:pg_max_smallint) { Yeti::ActiveRecord::PG_MAX_SMALLINT }

  before do
    visit static_routes_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:assign_params) do
    {
      routing_plan_id: routing_plan.id.to_s,
      prefix: '_test',
      priority: '12',
      weight: '123',
      vendor_id: vendor.id.to_s
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :routing_plan_id
      check :Routing_plan_id
      select_by_value assign_params[:routing_plan_id], from: :routing_plan_id
    end

    if assign_params.key? :prefix
      check :Prefix
      fill_in :prefix, with: assign_params[:prefix]
    end

    if assign_params.key? :priority
      check :Priority
      fill_in :priority, with: assign_params[:priority]
    end

    if assign_params.key? :weight
      check :Weight
      fill_in :weight, with: assign_params[:weight]
    end

    if assign_params.key? :vendor_id
      check :Vendor_id
      select_by_value assign_params[:vendor_id], from: :vendor_id
    end
  end

  subject do
    fill_batch_form
    click_button :OK
  end

  context 'should check validates' do
    context 'when :prefix value with spaces' do
      let(:assign_params) { { prefix: 'string test' } }

      it 'should have error message' do
        subject
        expect(page).to have_selector '.flash', text: I18n.t('activerecord.errors.models.routing\plan_static_route.attributes.prefix.with_spaces')
      end
    end

    context 'when all fields filled with valid values' do
      it 'should have success message' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlanStaticRoute', be_present, assign_params, be_present
      end
    end
  end
end
