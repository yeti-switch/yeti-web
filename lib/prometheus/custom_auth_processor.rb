# frozen_string_literal: true

require_relative './base_processor'

class CustomerAuthProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_ca'

  def collect(data)
    format_metric(data)
  end
end
