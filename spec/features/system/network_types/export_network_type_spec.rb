# frozen_string_literal: true

RSpec.describe 'Export Networks Types', type: :feature do
  include_context :login_as_admin

  let!(:item) do
    create(:network_type)
  end

  before do
    visit system_network_types_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Name', item.name],
                           ['Uuid', item.uuid]
                         ]
                       )
  end
end
