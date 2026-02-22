# frozen_string_literal: true

RSpec.describe 'Billing Services New', js: true, bullet: [:n] do
  subject do
    visit new_service_path
    fill_form!
    click_submit('Create Service')
  end

  include_context :login_as_admin

  before do
    create_list(:service_type, 2)
    create_list(:account, 2)
  end

  let!(:service_type) { create(:service_type) }
  let!(:account) { create(:account) }
  let(:fill_form!) do
    fill_in 'Name', with: attributes[:name]
    fill_in_tom_select 'Account', with: attributes[:account].name, search: true
    fill_in_tom_select 'Type', with: attributes[:service_type].name
    fill_in 'Variables', with: attributes[:variables_json]
    fill_in 'Initial price', with: attributes[:initial_price]
    fill_in 'Renew price', with: attributes[:renew_price]
  end
  let(:attributes) do
    {
      name: 'Test',
      account:,
      service_type:,
      variables_json: '{"key": "value"}',
      initial_price: 10.50,
      renew_price: 5.0
    }
  end

  it 'creates service' do
    expect {
      subject
      expect(page).to have_flash_message('Service was successfully created.', type: :notice, exact: true)
    }.to change { Billing::Service.count }.by(1)
    service = Billing::Service.last
    expect(service).to have_attributes(
                              name: attributes[:name],
                              account: attributes[:account],
                              type: attributes[:service_type],
                              variables: JSON.parse(attributes[:variables_json]),
                              renew_at: nil,
                              renew_period_id: nil,
                              initial_price: attributes[:initial_price],
                              renew_price: attributes[:renew_price]
                            )
    expect(page).to have_current_path service_path(service)
    expect(page).to have_attribute_row('ID', exact_text: service.id.to_s)
  end

  context 'without variables' do
    let(:attributes) do
      super().merge variables_json: ''
    end

    it 'creates service' do
      expect {
        subject
        expect(page).to have_flash_message('Service was successfully created.', type: :notice, exact: true)
      }.to change { Billing::Service.count }.by(1)
      service = Billing::Service.last
      expect(service).to have_attributes(
                           name: attributes[:name],
                           account: attributes[:account],
                           type: attributes[:service_type],
                           variables: nil,
                           renew_at: nil,
                           renew_period_id: nil,
                           initial_price: attributes[:initial_price],
                           renew_price: attributes[:renew_price]
                         )
      expect(page).to have_current_path service_path(service)
      expect(page).to have_attribute_row('ID', exact_text: service.id.to_s)
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
      }.not_to change { Billing::Service.count }
      expect(page).to have_current_path services_path
      expect(page).to have_field 'Name', with: attributes[:name]
    end
  end

  context 'with empty form' do
    let(:fill_form!) { nil }

    it 'does not create service type' do
      expect {
        subject
        expect(page).to have_semantic_error_texts(
                          'Account must exist',
                          'Type must exist',
                          "Initial price can't be blank",
                          "Renew price can't be blank"
                        )
      }.not_to change { Billing::Service.count }
      expect(page).to have_current_path services_path
      expect(page).to have_field 'Name', with: ''
    end
  end
end
