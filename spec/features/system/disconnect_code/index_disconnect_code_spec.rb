# frozen_string_literal: true

RSpec.describe 'Index System Disconnect Codes', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    disconnect_codes = DisconnectCode.last(2)
    visit disconnect_codes_path
    disconnect_codes.each do |disconnect_code|
      expect(page).to have_css('.resource_id_link', text: disconnect_code.id)
    end
  end

  describe 'GET /disconnect_codes/search' do
    let!(:disconnect_code) { DisconnectCode.where(code: 480).first || DisconnectCode.take! }

    it 'returns matching codes as id/value pairs by code or reason' do
      visit "/disconnect_codes/search?q[search_for]=#{disconnect_code.code}"

      json = JSON.parse(page.body)
      entry = json.find { |i| i['id'] == disconnect_code.id }
      expect(entry).to eq('id' => disconnect_code.id, 'value' => disconnect_code.display_name)
    end

    it 'is searchable by record id' do
      visit "/disconnect_codes/search?q[search_for]=#{disconnect_code.id}"

      json = JSON.parse(page.body)
      entry = json.find { |i| i['id'] == disconnect_code.id }
      expect(entry).to eq('id' => disconnect_code.id, 'value' => disconnect_code.display_name)
    end

    it 'includes the record id in the displayed value' do
      visit "/disconnect_codes/search?q[search_for]=#{disconnect_code.code}"

      entry = JSON.parse(page.body).find { |i| i['id'] == disconnect_code.id }
      expect(entry['value']).to end_with("| #{disconnect_code.id}")
    end

    it 'returns an empty array when nothing matches' do
      visit '/disconnect_codes/search?q[search_for]=zzz-no-such-code'

      expect(JSON.parse(page.body)).to eq([])
    end
  end
end
