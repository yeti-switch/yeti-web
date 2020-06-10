# frozen_string_literal: true

RSpec.describe 'Index Log Events', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    events = create_list(:event, 2)
    visit events_path
    events.each do |event|
      expect(page).to have_css('.resource_id_link', text: event.id)
    end
  end
end
