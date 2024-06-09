# frozen_string_literal: true

RSpec.describe 'Billing Services Edit', js: true, bullet: [:n] do
  subject do
    visit edit_service_path(record.id)
    fill_form!
    click_submit('Update Service')
  end

  include_context :login_as_admin

  let(:fill_form!) do
    fill_in 'Name', with: attributes[:name]
  end
  let(:attributes) do
    { name: 'Test new' }
  end
  let!(:record) { create(:service, record_attrs) }
  let(:record_attrs) { {} }

  it 'updates service' do
    old_attrs = record.reload.attributes.symbolize_keys
    subject
    expect(page).to have_flash_message('Service was successfully updated.', type: :notice, exact: true)
    expect(record.reload).to have_attributes(
                              **old_attrs,
                              name: attributes[:name]
                            )
    expect(page).to have_current_path service_path(record.id)
    expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
  end

  context 'with empty renew_price' do
    let(:fill_form!) do
      fill_in 'Renew price', with: attributes[:renew_price]
    end
    let(:attributes) do
      { renew_price: '' }
    end

    it 'does not update service' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Renew price can't be blank"
                        )
      }.not_to change { record.reload.attributes }
      expect(page).to have_current_path service_path(record.id)
      expect(page).to have_field 'Renew price', with: ''
    end
  end
end
