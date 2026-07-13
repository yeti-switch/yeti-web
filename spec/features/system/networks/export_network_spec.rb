# frozen_string_literal: true

RSpec.describe 'Export Networks', type: :feature do
  include_context :login_as_admin

  # A dedicated network type no seeded network references, so the export renders
  # exactly these rows instead of serializing the whole seeded sys.networks
  # table just to assert on a handful.
  let!(:network_type) { create(:network_type) }
  let!(:items) { create_list(:network_uniq, 3, network_type: network_type) }

  before do
    visit system_networks_path(format: :csv, q: { type_id_eq: network_type.id })
  end

  subject { CSV.parse(page.body) }

  it 'has expected header and values' do
    expect(subject.first).to eq(['Id', 'Name', 'Network type name', 'Uuid'])
    expect(subject.drop(1)).to match_array(
      items.map do |item|
        [
          item.id.to_s,
          item.name,
          item.network_type.name,
          item.uuid
        ]
      end
    )
  end
end
