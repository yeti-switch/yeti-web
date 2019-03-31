# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Interval CDR Scheduler', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_interval_cdr_scheduler_path
  end
end
