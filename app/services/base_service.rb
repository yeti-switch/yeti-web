# frozen_string_literal: true

class BaseService
  class_attribute :logger
  self.logger ||= Rails.logger

  def logger
    self.class.logger
  end
end
