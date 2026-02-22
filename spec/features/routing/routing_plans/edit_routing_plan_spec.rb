# frozen_string_literal: true

RSpec.describe 'Edit Routing Plan', type: :feature, js: true do
  include_context :login_as_admin

  subject do
    visit edit_routing_routing_plan_path(routing_plan.id)
  end

  let!(:routing_plan) { FactoryBot.create(:routing_plan, **routing_plan_attrs) }
  let(:routing_plan_attrs) do
    {
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
    }
  end

  let!(:src_numberlist) { FactoryBot.create(:numberlist) }
  let!(:dst_numberlist) { FactoryBot.create(:numberlist) }

  it 'should load edit page succesfully' do
    subject

    expect(page).to have_field_tom_select('SRC Numberlist', with: src_numberlist.display_name)
    expect(page).to have_field_tom_select('DST Numberlist', with: dst_numberlist.display_name)
  end
end
