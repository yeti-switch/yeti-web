# frozen_string_literal: true

RSpec.describe 'Routing plan details' do
  subject do
    visit routing_routing_plan_path(routing_plan.id)
  end

  include_context :login_as_admin

  let!(:routing_plan) do
    FactoryBot.create(:routing_plan, :filled)
  end

  it 'renders details page' do
    subject
    expect(page).to have_attribute_row('ID', exact_text: routing_plan.id.to_s)
  end
end
