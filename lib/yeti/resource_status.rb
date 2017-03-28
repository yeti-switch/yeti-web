module Yeti
  module ResourceStatus
    def self.included(base)
      base.scope :disabled, -> { base.where enabled: false }
      base.scope :enabled, -> { base.where enabled: true }
    end

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