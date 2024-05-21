# frozen_string_literal: true

RSpec.describe 'Billing Service Types New', js: true, bullet: [:n] do
  subject do
    visit new_service_type_path
    fill_form!
    click_submit('Create Service type')
  end

  include_context :login_as_admin

  let(:fill_form!) do
    fill_in 'Name', with: attributes[:name]
    fill_in 'Provisioning class', with: attributes[:provisioning_class]
    fill_in 'Variables', with: attributes[:variables_json]
    check 'Force renew' if attributes[:force_renew]
  end
  let(:attributes) do
    {
      name: 'Test',
      force_renew: true,
      provisioning_class: 'Billing::Provisioning::Logging',
      variables_json: '{"key": "value"}'
    }
  end

  it 'creates service type' do
    expect {
      subject
      expect(page).to have_flash_message('Service type was successfully created.', type: :notice, exact: true)
    }.to change { Billing::ServiceType.count }.by(1)
    service_type = Billing::ServiceType.last
    expect(service_type).to have_attributes(
                              name: attributes[:name],
                              force_renew: true,
                              provisioning_class: attributes[:provisioning_class],
                              variables: JSON.parse(attributes[:variables_json])
                            )
    expect(page).to have_current_path service_type_path(service_type)
    expect(page).to have_attribute_row('ID', exact_text: service_type.id.to_s)
  end

  context 'without variables' do
    let(:attributes) do
      super().merge variables_json: ''
    end

    it 'creates service type' do
      expect {
        subject
        expect(page).to have_flash_message('Service type was successfully created.', type: :notice, exact: true)
      }.to change { Billing::ServiceType.count }.by(1)
      service_type = Billing::ServiceType.last
      expect(service_type).to have_attributes(
                                name: attributes[:name],
                                force_renew: true,
                                provisioning_class: attributes[:provisioning_class],
                                variables: nil
                              )
      expect(page).to have_current_path service_type_path(service_type)
      expect(page).to have_attribute_row('ID', exact_text: service_type.id.to_s)
    end
  end

  context 'with invalid variables JSON' do
    let(:attributes) do
      super().merge variables_json: '{"qwe'
    end

    it 'does not create service type' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                        'Variables must be a JSON object or empty'
                      )
      }.not_to change { Billing::ServiceType.count }
      expect(page).to have_current_path service_types_path
      expect(page).to have_field 'Name', with: attributes[:name]
    end
  end

  context 'with non-existing provisioning class' do
    let(:attributes) do
      super().merge provisioning_class: 'Billing::Provisioning::NonExisting'
    end

    it 'does not create service type' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          'Provisioning class is invalid'
                        )
      }.not_to change { Billing::ServiceType.count }
      expect(page).to have_current_path service_types_path
      expect(page).to have_field 'Name', with: attributes[:name]
    end
  end

  context 'with empty form' do
    let(:fill_form!) { nil }

    it 'does not create service type' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          "Name can't be blank",
                          "Provisioning class can't be blank"
                        )
      }.not_to change { Billing::ServiceType.count }
      expect(page).to have_current_path service_types_path
      expect(page).to have_field 'Name', with: ''
    end
  end
end
