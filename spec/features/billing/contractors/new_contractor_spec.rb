require 'spec_helper'

describe 'Create new Contractor', type: :feature, js: false do
  include_context :login_as_admin

  before do
    @smtp = create(:smtp_connection)
    visit new_contractor_path
  end

  include_context :fill_form, 'new_contractor' do
    let(:attributes) do
      {
          name: "Contractor",
          enabled: true,
          vendor: true,
          customer: true,
          description: "test description",
          address: "test address",
          phones: "32432432,32432432,3242",
          smtp_connection_id: @smtp.name

      }
    end

    it 'creates new contractor succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Contractor was successfully created.')

      expect(Contractor.last).to have_attributes(
                                     name: attributes[:name],
                                     enabled: attributes[:enabled],
                                     vendor: attributes[:vendor],
                                     customer: attributes[:customer],
                                     description: attributes[:description],
                                     address: attributes[:address],
                                     phones: attributes[:phones],
                                     smtp_connection_id: @smtp.id
                                 )
    end
  end

end
