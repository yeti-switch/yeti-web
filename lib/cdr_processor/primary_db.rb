# frozen_string_literal: true

module CdrProcessor
  # Lightweight abstract AR base for primary database connection (billing SP, etc).
  class PrimaryDb < ActiveRecord::Base
    self.abstract_class = true
  end
end
