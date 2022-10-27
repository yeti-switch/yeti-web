# frozen_string_literal: true

namespace :coverage do
  task :report do
    require_relative '../../spec/coverage_helper'
    CoverageHelper.parallel_report
  end
end
