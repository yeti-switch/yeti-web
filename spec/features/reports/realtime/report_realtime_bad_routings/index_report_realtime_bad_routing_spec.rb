# frozen_string_literal: true

# frozen_string_literal: true

require 'spec_helper'

describe 'bad routing', type: :feature do
  include_context :login_as_admin
  after do
    Report::Realtime::BadRouting.delete_all
  end
  let(:customers_auth) { create(:customers_auth) }
    let!(:routing) do
      create(:bad_routing)
    end
  context 'asdas' do
    it '' do
      visit report_realtime_bad_routings_path
      puts find('#main_content').text
      byebug
    end
  end
end
