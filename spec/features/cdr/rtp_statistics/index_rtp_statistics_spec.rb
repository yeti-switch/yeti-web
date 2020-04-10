# frozen_string_literal: true

require 'spec_helper'

describe 'RTP statistics index', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    rtp_statistics = create_list(:rtp_statistic, 2)
    visit rtp_statistics_path
    rtp_statistics.each do |rtp_statistic|
      expect(page).to have_css('.resource_id_link', text: rtp_statistic.id)
    end
  end
end
