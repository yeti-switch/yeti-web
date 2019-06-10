# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  delegate_all

  def self.object_class_name
    return nil if name.nil? || name.demodulize !~ /.+Decorator$/

    class_name = name.chomp('Decorator')
    namespace = object_class_namespace
    namespace.blank? ? class_name : "#{namespace}::#{class_name}"
  end

  def self.object_class_namespace
    nil
  end
end
