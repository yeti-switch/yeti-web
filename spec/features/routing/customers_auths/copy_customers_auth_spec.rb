# frozen_string_literal: true

# acts_as_clone is a shared functionality
# so we do not need to test every page
# we need to test every attribute type:
# - string, integer, array, inet, etc.
# CustomersAuth has all types of attributes
# Thats why it is perfect for testing "Copy"-action

RSpec.describe 'Copy Customers Auth', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  let(:record) { create(:customers_auth, attrs) }

  let(:attrs) do
    {
      name: 'Copy this name please',
      capacity: 10,
      enabled: true,
      reject_calls: true,
      check_account_balance: false,
      src_prefix: %w[foo bar],
      dst_prefix: %w[],
      ip: %w[127.0.0.1 216.3.128.0/26 0.0.0.0/0],
      tag_action_value: [@tag_ua.id, @tag_us.id]
    }
  end

  before do
    visit customers_auth_path(record.id)
    click_link 'Copy'
    find('#page_title', text: 'New Customers Auth') # wait page load
  end

  it 'check if every type of attribute cloned as expected' do
    within 'form#new_customers_auth' do
      # String
      expect(page).to have_field('Name', with: attrs[:name])
      # Number
      expect(page).to have_field('Capacity', with: attrs[:capacity])
      # Boolean
      expect(page).to have_field('Enabled', checked: true)
      expect(page).to have_field('Reject calls', checked: true)
      expect(page).to have_field('Check account balance', checked: false)
      # Relationship (belongs_to)
      expect(page).to have_select('Customer', selected: record.customer.display_name)
      # array of Strings
      expect(page).to have_field('SRC Prefix', with: attrs[:src_prefix].join(', '))
      expect(page).to have_field('DST Prefix', with: '')
      # array if Inet
      expect(page).to have_field('IP', with: attrs[:ip].join(', '))
      # array of Relationships
      expect(page).to have_select('Tag action value', selected: [@tag_ua.display_name, @tag_us.display_name])
    end
  end
end
