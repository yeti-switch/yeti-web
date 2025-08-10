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
        get search_time_zones_path(q: { search_for: 'canada' })
        expect(response_json).to include(
          { id: 'canada/atlantic', value: 'canada/atlantic' },
          { id: 'canada/central', value: 'canada/central' },
          { id: 'canada/eastern', value: 'canada/eastern' },
          { id: 'canada/mountain', value: 'canada/mountain' },
          { id: 'canada/newfoundland', value: 'canada/newfoundland' },
          { id: 'canada/pacific', value: 'canada/pacific' },
          { id: 'canada/saskatchewan', value: 'canada/saskatchewan' },
          { id: 'canada/yukon', value: 'canada/yukon' }
        )
      end
    end
  end
end
