# frozen_string_literal: true

RSpec.describe 'Export Dns Zones', type: :feature do
  include_context :login_as_admin

  before { create(:dns_zone) }

  let!(:item) do
    create(:dns_zone)
  end

  before do
    visit equipment_dns_zones_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Name', item.name],
                           ['Soa rname', item.soa_rname],
                           ['Soa mname', item.soa_mname],
                           ['Serial', item.serial.to_s],
                           ['Expire', item.expire.to_s],
                           ['Refresh', item.refresh.to_s],
                           ['Retry', item.retry.to_s ],
                           ['Minimum', item.minimum.to_s ]
                         ]
                       )
  end

end
