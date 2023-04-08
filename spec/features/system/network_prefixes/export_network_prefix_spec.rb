# frozen_string_literal: true

RSpec.describe 'Export Network Prefixes', type: :feature do
  include_context :login_as_admin


  let!(:item) do
    create(:network_prefix)
  end

  before do
    visit system_network_prefixes_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Prefix', item.prefix],
                           ['Number min length', item.number_min_length.to_s],
                           ['Number max length', item.number_max_length.to_s],
                           ['Country name', item.country.name],
                           ['Network name', item.network.name],
                           ['Uuid', item.uuid ]
                         ]
                       )
  end
end
