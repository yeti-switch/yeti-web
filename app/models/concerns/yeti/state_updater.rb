# frozen_string_literal: true

module Yeti
  module StateUpdater
    extend ActiveSupport::Concern
    included do
      class_attribute :state_names

      after_save do
        self.class.increment_state_value
      end

      after_destroy do
        self.class.increment_state_value
      end

      def self.increment_state_value
        state_names.each do |s|
          System::State.increment_counter(:value, s)
        end
      end
    end
  end
end
