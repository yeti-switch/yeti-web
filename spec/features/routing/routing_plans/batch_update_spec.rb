# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlan, :js do
  include_context :login_as_admin
  let!(:_routing_plans) { FactoryBot.create_list :routing_plan, 3 }
  let(:success_message) { I18n.t('flash.actions.batch_actions.batch_update.job_scheduled') }

  before do
    visit routing_routing_plans_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  let(:assign_params) do
    {
      sorting_id: Routing::RoutingPlan::SORTING_LCR_PRIO_CONTROL.to_s,
      use_lnp: true,
      rate_delta_max: '2.5'
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :sorting_id
      check :Sorting_id
      select_by_value assign_params[:sorting_id], from: :sorting_id
    end

    if assign_params.key? :use_lnp
      check :Use_lnp
      select_by_value assign_params[:use_lnp], from: :use_lnp
    end

    if assign_params.key? :rate_delta_max
      check :Rate_delta_max
      fill_in :rate_delta_max, with: assign_params[:rate_delta_max]
    end
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  context 'should check validates for the field:' do
    context 'when :rate_delta_max field have empty value' do
      let(:assign_params) { { rate_delta_max: '' } }

      it "should have error: can't be blank" do
        subject
        expect(page).to have_selector '.flash', text: "can't be blank"
      end
    end

    context 'when all fields filled with valid values' do
      it 'should pass validations' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Routing::RoutingPlan', be_present, assign_params, be_present
      end
    end
  end
end
