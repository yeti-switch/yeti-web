# frozen_string_literal: true

# == Schema Information
#
# Table name: delayed_jobs
#
#  id          :integer(4)       not null, primary key
#  attempts    :integer(4)       default(0), not null
#  failed_at   :timestamptz
#  handler     :text             not null
#  last_error  :text
#  locked_at   :timestamptz
#  locked_by   :string(255)
#  priority    :integer(4)       default(0), not null
#  queue       :string(255)
#  run_at      :timestamptz
#  unique_name :string
#  created_at  :timestamptz      not null
#  updated_at  :timestamptz      not null
#
# Indexes
#
#  delayed_jobs_priority  (priority,run_at)
#

class BackgroundTask < ApplicationRecord
  self.table_name = 'delayed_jobs'

  scope :active, -> { where(failed_at: nil) }
  scope :running, -> { where.not(locked_by: nil) }
  scope :failed, -> { where.not(failed_at: nil) }
  scope :pending, -> { where(attempts: 0, locked_by: nil) }
  scope :to_retry, -> { where('failed_at IS NULL AND attempts > ?', 0) }

  def payload_object
    @payload_object ||= YAML.load_dj(handler)
  rescue TypeError, LoadError, NameError, ArgumentError, SyntaxError, Psych::SyntaxError => e
    raise DeserializationError, "Job failed to load: #{e.message}. Handler: #{handler.inspect}"
  end
end
