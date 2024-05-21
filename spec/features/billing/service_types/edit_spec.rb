# frozen_string_literal: true

RSpec.describe 'Billing Service Types Edit', js: true, bullet: [:n] do
  subject do
    visit edit_service_type_path(record.id)
    fill_form!
    click_submit('Update Service type')
  end

  include_context :login_as_admin

  let(:fill_form!) do
    fill_in 'Name', with: attributes[:name]
  end
  let(:attributes) do
    { name: 'Test new' }
  end
  let!(:record) { create(:service_type, record_attrs) }
  let(:record_attrs) { {} }

  it 'updates service type' do
    old_attrs = record.attributes.symbolize_keys
    subject
    expect(page).to have_flash_message('Service type was successfully updated.', type: :notice, exact: true)
    expect(record.reload).to have_attributes(
                              **old_attrs,
                              name: attributes[:name]
                            )
    expect(page).to have_current_path service_type_path(record.id)
    expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
  end

  context 'with empty name' do
    let(:attributes) do
      { name: '' }
    end

    it 'does not update service type' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Name can't be blank"
                        )
      }.not_to change { record.reload.attributes }
      expect(page).to have_current_path service_type_path(record.id)
      expect(page).to have_field 'Name', with: ''
    end
  end
end
