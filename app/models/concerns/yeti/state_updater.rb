# frozen_string_literal: true

module Yeti
  module StateUpdater
    extend ActiveSupport::Concern
    included do
      class_attribute :state_name

      after_save do
        self.class.increment_state_value
      end

      after_destroy do
        self.class.increment_state_value
      end

      def self.increment_state_value
        System::State.increment_counter(:value, state_name)
      end
    end
  end
end
