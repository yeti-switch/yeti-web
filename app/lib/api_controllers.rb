# frozen_string_literal: true

module ApiControllers
  mattr_accessor :list

  def list
    return @list if @list

    @list = Rails.application.routes.set.anchored_routes.map(&:defaults).filter_map do |route|
      if route[:controller].start_with?('api/')
        "#{route[:controller].camelize}Controller"
      end
    end
  end

  module_function :list
end
