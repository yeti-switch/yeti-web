require 'spec_helper'

describe 'Copy Destination', type: :feature do
  include_context :login_as_admin

  let(:record) { create(:destination, attrs) }

  let(:attrs) do
    {
      prefix: '123'
    }
  end

  before do
    visit destination_path(record.id)
    click_link 'Copy'
  end

  it 'check only not standart attribute **batch_prefix**' do
    within 'form#new_routing_destination' do
      expect(page).to have_field('Prefix', with: attrs[:prefix])
    end
  end
end
