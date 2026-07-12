# frozen_string_literal: true

RSpec.describe 'Export Network Prefixes', type: :feature do
  include_context :login_as_admin

  # A dedicated country no seeded prefix references, so the export renders
  # exactly these rows instead of serializing the whole sys.network_prefixes
  # table (~486k seeded rows in the test DB) just to assert on a handful.
  let!(:country) { create(:country_uniq) }
  let!(:items) { create_list(:network_prefix, 3, country: country) }

  before do
    visit system_network_prefixes_path(format: :csv, q: { country_id_eq: country.id })
  end

  subject { CSV.parse(page.body) }

  it 'has expected header and values' do
    expect(subject.first).to eq(
      ['Id', 'Prefix', 'Number min length', 'Number max length', 'Country name', 'Network name', 'Uuid']
    )
    expect(subject.drop(1)).to match_array(
      items.map do |item|
        [
          item.id.to_s,
          item.prefix,
          item.number_min_length.to_s,
          item.number_max_length.to_s,
          item.country.name,
          item.network.name,
          item.uuid
        ]
      end
    )
  end
end
