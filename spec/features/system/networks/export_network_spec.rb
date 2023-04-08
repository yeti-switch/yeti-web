# frozen_string_literal: true

RSpec.describe 'Export Networks', type: :feature do
  include_context :login_as_admin

  let!(:item) do
    create(:network)
  end

  before do
    visit system_networks_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Name', item.name],
                           ['Network type name', item.network_type.name],
                           ['Uuid', item.uuid]
                         ]
                       )
  end
end
