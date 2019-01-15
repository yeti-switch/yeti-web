# frozen_string_literal: true

module Yeti
  module SensorReloader
    extend ActiveSupport::Concern
    included do
      before_save do
        Event.reload_sensors
      end

      before_destroy do
        Event.reload_sensors
      end
    end
  end
end
