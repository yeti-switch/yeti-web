# frozen_string_literal: true

RSpec.describe Routing::SimulationForm, 'index' do
  include_context :login_as_admin
  subject { visit routing_simulation_path }

  it 'should load SimulationForm page' do
    subject
    expect(page).to have_content 'Routing simulation'
    expect(page).to have_current_path '/routing_simulation'
    expect(page).to_not have_css 'flash-warning'
    expect(page).to_not have_css 'flash-error'
  end
end
