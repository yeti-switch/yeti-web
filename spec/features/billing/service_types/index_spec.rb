# frozen_string_literal: true

RSpec.describe 'Billing Service Types Index', js: true, bullet: [:n] do
  subject do
    visit service_types_path
  end

  include_context :login_as_admin

  let!(:records) do
    [
      create(:service_type),
      create(:service_type, force_renew: true),
      create(:service_type, variables: nil)
    ]
  end

  it 'displays correct table' do
    subject
    expect(page).to have_table_row(count: records.count)
    records.each do |record|
      expect(page).to have_table_cell(column: 'ID', exact_text: record.id.to_s)
    end
  end
end
