# frozen_string_literal: true

RSpec.describe 'Create new Routing Simulation', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for Routing::SimulationForm, 'new'
  include_context :login_as_admin

  let!(:pop) { FactoryBot.create(:pop) }

  before do
    visit routing_simulation_path

    aa_form.set_text 'Remote ip', '1.1.1.1'
    aa_form.set_text 'Remote port', '5060'
    aa_form.set_text 'Src number', '1223321'
    aa_form.set_text 'Dst number', '122231'
  end

  it 'creates record' do
    subject

    expect(page).to have_content 'log'
    expect(page).to have_content 'result'
    expect(page).to have_table_cell(text: '1223321', column: 'Src prefix in')
    expect(page).to have_table_cell(text: '1223321', column: 'Src prefix out')
  end
end
