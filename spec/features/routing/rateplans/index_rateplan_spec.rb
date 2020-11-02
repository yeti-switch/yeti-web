# frozen_string_literal: true

RSpec.describe 'Index Rateplans', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    reteplans = create_list(:rateplan, 2, :filled)
    visit routing_rateplans_path
    reteplans.each do |reteplan|
      expect(page).to have_css('.resource_id_link', text: reteplan.id)
    end
  end
end
