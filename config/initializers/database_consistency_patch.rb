# frozen_string_literal: true

if Rails.env.test?
  require 'database_consistency/rescue_error'

  # This patch is needed to change location log file for this gem
  # to be able to download the log file from CI
  module DatabaseConsistencyPatch
    private

    def filename
      @filename ||= "log/database_consistency_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}"
    end
  end

  DatabaseConsistency::RescueError.prepend DatabaseConsistencyPatch
end
