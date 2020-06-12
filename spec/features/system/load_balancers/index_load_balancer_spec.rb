# frozen_string_literal: true

RSpec.describe 'Index System Load Balancer', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_load_balancers = create_list(:system_load_balancer, 2, :uniq)
    visit system_load_balancers_path
    system_load_balancers.each do |system_load_balancer|
      expect(page).to have_css('.resource_id_link', text: system_load_balancer.id)
    end
  end
end
