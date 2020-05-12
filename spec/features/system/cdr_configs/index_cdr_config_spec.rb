# frozen_string_literal: true

require 'spec_helper'

describe 'Index System Cdr Configs', type: :feature do
  include_context :login_as_admin

  let(:cdr_config) { System::CdrConfig.take || create(:cdr_config) }
  it 'n+1 checks' do
    CdrRoundMode = System::CdrRoundMode.find(cdr_config.call_duration_round_mode_id).name
    visit system_cdr_configs_path
    expect(page).to have_http_status(200)
    expect(page).to have_css('tr.row-call_duration_round_mode td', text: CdrRoundMode.to_s)
  end
end
