# frozen_string_literal: true

RSpec.describe 'app/admin/cdr/time_zones.rb' do
  include_context :login_as_admin

  describe 'GET /time_zones/search' do
    context 'when search by specific valid time zone' do
      it 'should render proper time zone' do
        get search_time_zones_path(q: { search_for: 'europe/kyiv' })
        expect(response_json).to include({ id: 'europe/kyiv', value: 'europe/kyiv' })
        get search_time_zones_path(q: { search_for: 'new_york' })
        expect(response_json).to include({ id: 'america/new_york', value: 'america/new_york' })
        get search_time_zones_path(q: { search_for: 'Australia' })
        expect(response_json).to include(
          { id: 'australia/adelaide', value: 'australia/adelaide' },
          { id: 'australia/brisbane', value: 'australia/brisbane' },
          { id: 'australia/broken_hill', value: 'australia/broken_hill' },
          { id: 'australia/canberra', value: 'australia/canberra' },
          { id: 'australia/currie', value: 'australia/currie' },
          { id: 'australia/darwin', value: 'australia/darwin' },
          { id: 'australia/eucla', value: 'australia/eucla' },
          { id: 'australia/hobart', value: 'australia/hobart' }
        )
      end
    end
  end
end
