# frozen_string_literal: true

RSpec.describe 'Create new Pop', type: :feature do
  include_context :login_as_admin

  before do
    visit new_pop_path
  end

  include_context :fill_form, 'new_pop' do
    let(:attributes) do
      {
        name: 'test POP'
      }
    end

    it 'creates new POP succesfully' do
      click_on_submit

      expect(page).to have_css('.flash_notice', text: 'Pop was successfully created.')

      expect(Pop.last).to have_attributes(
        name: attributes[:name]
      )
    end
  end
end
