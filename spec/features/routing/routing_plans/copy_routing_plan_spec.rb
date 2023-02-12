# frozen_string_literal: true

RSpec.describe 'Copy Routing Plan action', js: true do
  subject do
    visit routing_routing_plan_path(routing_plan.id)
    click_action_item 'Copy'
    fill_form!
  end

  shared_examples :creates_routing_plan_copy do
    it 'creates new Routing Plan with identical fields' do
      expect {
        subject
        expect(page).to have_page_title(new_name)
      }.to change { Routing::RoutingPlan.count }.by(1)
                                                .and change { Routing::RoutingGroup.count }.by(0)
      new_routing_plan = Routing::RoutingPlan.last
      expect(new_routing_plan).to have_attributes(
                                    name: new_name,
                                    routing_groups: match_array(routing_plan.routing_groups)
                                  )
    end
  end

  include_context :login_as_admin

  before do
    create :admin_user, username: 'test copy'
  end

  let(:fill_form!) do
    fill_in 'Name', with: new_name
    click_button 'Create'
  end

  let!(:routing_plan) do
    FactoryBot.create :routing_plan, :filled
  end

  let(:new_name) { routing_plan.name + '_copy' }

  include_examples :creates_routing_plan_copy
end
