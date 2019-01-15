# frozen_string_literal: true

class BaseJob < ActiveRecord::Base
  self.table_name = 'sys.jobs'
  self.store_full_sti_class = false

  #  attr_protected :type, :id

  scope :available, -> { where(running: false) }
  scope :running, -> { where(running: true) }

  def logger
    Rails.logger
  end

  def start!
    update_column(:running, true)
    after_start
  end

  def run!
    transaction do
      execute
    ensure
      finish!
    end
  end

  def finish!
    before_finish
    #    release_lock!
  end

  def self.launch!(type_name_or_id)
    scheduled_job = transaction do
      begin
        job = available.lock('FOR UPDATE NOWAIT')
                       .where(BaseJob.arel_table[:id].eq(type_name_or_id)
                      .or(BaseJob.arel_table[:type].eq(type_name_or_id.to_s))).first!
        logger.info { "Starting scheduler #{job.type}" }
        job.start!
      rescue StandardError => e
        logger.warn { e.message }
        logger.warn { e.backtrace.join("\n") }
        raise ActiveRecord::RecordNotFound
      end
      job
    end
    begin
      scheduled_job.run!
    ensure
      scheduled_job.release_lock!
    end
  end

  def release_lock!
    update_columns(running: false, updated_at: Time.now)
  end

  protected

  def self.find_sti_class(type_name)
    ActiveSupport::Dependencies.constantize "Jobs::#{type_name}"
  end

  def before_finish; end

  def after_start; end

  def execute
    raise StandardError, 'Not Implemented'
  end
end
