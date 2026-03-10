# frozen_string_literal: true

module CdrProcessor
  # Lightweight abstract AR base for CDR database connection (PGQ operations).
  class CdrDb < ActiveRecord::Base
    self.abstract_class = true
  end
end
