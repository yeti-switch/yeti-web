# frozen_string_literal: true

require 'spec_helper'

describe 'Create new Custom CDR Scheduler', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit new_custom_cdr_scheduler_path
  end
end
