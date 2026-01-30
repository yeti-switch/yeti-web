# frozen_string_literal: true

RSpec.describe 'Create new Routing Plan', type: :feature, js: true do
  include_context :login_as_admin

  subject do
    visit new_routing_routing_plan_path
    fill_form!
    click_on 'Create Routing plan'
  end

  let(:fill_form!) do
    fill_in 'Name', with: 'test routing plan'
    check 'Use lnp'
    fill_in 'Rate delta max', with: 0.11
    fill_in 'Max rerouting attempts', with: 8
    check 'Validate dst number format'
    check 'Validate dst number network'
    check 'Validate src number format'
    check 'Validate src number network'
    fill_in_tom_select 'DST Numberlist', with: dst_numberlist.display_name, ajax: true
    fill_in_tom_select 'SRC Numberlist', with: src_numberlist.display_name, ajax: true
  end

  let!(:src_numberlist) { FactoryBot.create(:numberlist) }
  let!(:dst_numberlist) { FactoryBot.create(:numberlist) }

  it 'creates new routing plan succesfully' do
    subject

    expect(page).to have_flash_message('Routing plan was successfully created.', type: :notice)
    expect(Routing::RoutingPlan.last).to have_attributes(
                                           name: 'test routing plan',
                                           use_lnp: true,
                                           rate_delta_max: 0.11,
                                           max_rerouting_attempts: 8,
                                           validate_dst_number_format: true,
                                           validate_dst_number_network: true,
                                           validate_src_number_format: true,
                                           validate_src_number_network: true,
                                           src_numberlist:,
                                           dst_numberlist:
                                         )
  end
end
