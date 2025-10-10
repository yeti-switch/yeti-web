# frozen_string_literal: true

module Yeti
  module Scheduler
    extend ActiveSupport::Concern

    included do
      belongs_to :scheduler, class_name: 'System::Scheduler', foreign_key: :scheduler_id, optional: true
      scope :scheduled, -> { where("#{table_name}.scheduler_id IS NOT NULL") }
    end
  end
end
