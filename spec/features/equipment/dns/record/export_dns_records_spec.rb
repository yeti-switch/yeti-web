# frozen_string_literal: true

RSpec.describe 'Export Dns Records', type: :feature do
  include_context :login_as_admin

  before { create(:dns_record) }

  let!(:item) do
    create(:dns_record)
  end

  before do
    visit equipment_dns_records_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Name', item.name],
                           ['Zone name', item.zone.name],
                           ['Record type', item.record_type],
                           ['Content', item.content],
                           ['Contractor name', item.contractor.try(:name)]
                         ]
                       )
  end
end
