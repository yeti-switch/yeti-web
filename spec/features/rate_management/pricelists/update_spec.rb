# frozen_string_literal: true

RSpec.describe 'Rate Management Pricelist Update', js: true do
  include_context :login_as_admin

  subject do
    visit edit_rate_management_pricelist_path(pricelist)
    fill_form!
    click_on 'Update Pricelist'
  end

  let(:pricelist) { FactoryBot.create(:rate_management_pricelist, :with_project) }

  let(:new_name) { 'new_pricelist_name' }
  let(:new_filename) { 'new_filename' }
  let(:fill_form!) do
    fill_in 'Name', with: new_name
    fill_in 'Filename', with: new_filename
  end

  it 'should be update pricelist' do
    subject
    expect(page).to have_flash_message('Pricelist was successfully updated.', type: :notice)
    expect(pricelist.reload).to have_attributes(
                            name: new_name,
                            filename: new_filename
                          )
  end
end
