# frozen_string_literal: true

RSpec.describe BatchUpdateForm::RoutingPlan, :js do
  include_context :login_as_admin
  let!(:_routing_plans) { create_list :routing_plan, 3 }
  let(:success_message) { I18n.t('flash.actions.batch_actions.batch_update.job_scheduled') }
  let!(:sorting) { Sorting.take || create(:sorting) }
  before do
    visit routing_routing_plans_path
    click_button 'Update batch'
  end

  context 'should check validates for the field:' do
    context '"sorting_id"' do
      it 'should change value lonely' do
        check :Sorting_id
        select sorting.name, from: :sorting_id
        click_button :OK
        expect(page).to have_selector '.flash', text: success_message
      end
    end

    context '"use_lnp"' do
      it 'should change value' do
        check :Use_lnp
        select :No, from: :use_lnp
        click_button :OK
        expect(page).to have_selector '.flash', text: success_message
      end
    end

    context '"rate_delta_max"' do
      before { check :Rate_delta_max }
      context 'should have error:' do
        it "can't be blank and not a number" do
          fill_in :rate_delta_max, with: nil
          click_button :OK
          expect(page).to have_selector '.flash', text: "can't be blank"
          expect(page).to have_selector '.flash', text: 'not a number'
        end

        it 'must be greater than or equal to zero' do
          fill_in :rate_delta_max, with: -1
          click_button :OK
          expect(page).to have_selector '.flash', text: 'must be greater than or equal to 0'
        end
      end

      context 'should have success' do
        it 'change value lonely' do
          fill_in :rate_delta_max, with: 5
          click_button :OK
          expect(page).to have_selector '.flash', text: success_message
        end
      end
    end

    it 'all fields should have success and pass validates' do
      check :Sorting_id
      select sorting.name, from: :sorting_id

      check :Use_lnp
      select :Yes, from: :use_lnp

      check :Rate_delta_max
      fill_in :rate_delta_max, with: 5
    end
  end
end
