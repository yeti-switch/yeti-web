# frozen_string_literal: true

RSpec.describe 'Billing Service Types Show', js: true, bullet: [:n] do
  subject do
    visit service_type_path(record.id)
  end

  include_context :login_as_admin

  let!(:record) { create(:service_type, record_attrs) }
  let(:record_attrs) { {} }

  it 'displays correct attributes' do
    subject
    expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
    expect(page).to have_attribute_row('Name', exact_text: record.name)
    expect(page).to have_attribute_row('Provisioning class', exact_text: record.provisioning_class)
    within_panel('Variables') do
      expect(page).to have_text JSON.pretty_generate(record.variables)
    end
  end

  context 'without variables' do
    let(:record_attrs) do
      super().merge variables: nil
    end

    it 'displays correct attributes' do
      subject
      expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
      within_panel('Variables') do
        expect(page).to have_text 'null'
      end
    end
  end
end
