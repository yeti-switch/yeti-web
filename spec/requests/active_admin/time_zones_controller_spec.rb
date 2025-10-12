# frozen_string_literal: true

RSpec.describe 'app/admin/system/time_zones.rb' do
  include_context :login_as_admin

  describe 'GET /time_zones/search' do
    context 'when search by specific valid time zone' do
      it 'should render proper time zone' do
        get search_time_zones_path(q: { search_for: 'europe/kyiv' })
        expect(response_json).to include({ id: 'Europe/Kyiv', value: 'Europe/Kyiv' })
        get search_time_zones_path(q: { search_for: 'new_york' })
        expect(response_json).to include({ id: 'America/New_York', value: 'America/New_York' })
        get search_time_zones_path(q: { search_for: 'Australia' })
        expect(response_json).to include(
          { id: 'Australia/Adelaide', value: 'Australia/Adelaide' },
          { id: 'Australia/Brisbane', value: 'Australia/Brisbane' },
          { id: 'Australia/Broken_Hill', value: 'Australia/Broken_Hill' },
          { id: 'Australia/Canberra', value: 'Australia/Canberra' },
          { id: 'Australia/Currie', value: 'Australia/Currie' },
          { id: 'Australia/Darwin', value: 'Australia/Darwin' },
          { id: 'Australia/Eucla', value: 'Australia/Eucla' },
          { id: 'Australia/Hobart', value: 'Australia/Hobart' }
        )
      end
    end
  end
end
