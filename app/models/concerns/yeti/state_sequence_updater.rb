# frozen_string_literal: true

module Yeti
  module StateSequenceUpdater
    extend ActiveSupport::Concern
    included do
      class_attribute :state_sequence_name

      after_save do
        self.class.increment_state_sequence
      end

      after_destroy do
        self.class.increment_state_sequence
      end

      def self.increment_state_sequence
        SqlCaller::Yeti.execute "SELECT nextval('#{state_sequence_name}')"
      end

      def self.state_sequence
        SqlCaller::Yeti.select_value "SELECT last_value FROM #{state_sequence_name}"
      end
    end
  end
end
