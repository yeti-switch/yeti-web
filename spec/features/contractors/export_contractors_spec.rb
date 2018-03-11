require 'spec_helper'

describe 'Export Contractors', type: :feature do
  include_context :login_as_admin

  before { create(:customer) }

  let!(:item) do
    create :vendor
  end

  before do
    visit contractors_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id',       item.id.to_s],
        ['Name',     item.name],
        ['Enabled',  item.enabled.to_s],
        ['Vendor',   item.vendor.to_s],
        ['Customer', item.customer.to_s]
      ]
    )
  end
end
