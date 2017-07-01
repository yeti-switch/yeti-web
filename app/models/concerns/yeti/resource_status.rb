module Yeti
  module ResourceStatus
    extend ActiveSupport::Concern
    included do
      scope :disabled, -> { where enabled: false }
      scope :enabled, -> { where enabled: true }

      def status_sym
        self.enabled? ? :enabled : :disabled
      end

      def enable!
        self.enabled = true
        save!
      end

      def disable!
        self.enabled = false
        save!
      end

      def disabled?
        !self.enabled
      end

    end
  end
end