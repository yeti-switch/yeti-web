# frozen_string_literal: true

RSpec.describe 'Billing Services Show', js: true, bullet: [:n] do
  subject do
    visit service_path(record.id)
  end

  include_context :login_as_admin

  let!(:account) { create(:account) }
  let!(:service_type) { create(:service_type) }
  let!(:record) { create(:service, :renew_daily, record_attrs) }
  let(:record_attrs) { { name: 'test', account:, type: service_type } }

  it 'displays correct attributes' do
    subject
    expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
    expect(page).to have_attribute_row('Name', exact_text: record.name.to_s)
    expect(page).to have_attribute_row('Account', exact_text: record.account.display_name)
    expect(page).to have_attribute_row('Type', exact_text: record.type.name)
    expect(page).to have_attribute_row('Renew At', exact_text: record.renew_at.strftime('%F %T'))
    expect(page).to have_attribute_row('Renew Period', exact_text: record.renew_period.to_s)
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

  context 'without renew_period' do
    let(:record_attrs) do
      super().merge renew_period_id: nil, renew_at: nil
    end

    it 'displays correct attributes' do
      subject
      expect(page).to have_attribute_row('ID', exact_text: record.id.to_s)
      expect(page).to have_attribute_row('Renew At', exact_text: 'EMPTY')
      expect(page).to have_attribute_row('Renew Period', exact_text: 'Disabled')
    end
  end
end
