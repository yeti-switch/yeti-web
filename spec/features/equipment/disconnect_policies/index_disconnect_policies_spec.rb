# frozen_string_literal: true

RSpec.describe 'Index Disconnect policies', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    disconnect_policies = create_list(:disconnect_policy, 2, :filled)
    visit disconnect_policies_path
    disconnect_policies.each do |disconnect_policy|
      expect(page).to have_css('.resource_id_link', text: disconnect_policy.id)
    end
  end
end
