# frozen_string_literal: true

module ActiveAdmin
  class PagePolicy < ::RolePolicy
    class Scope < RolePolicy::Scope
    end

    SECTION_NAMES = {
      'Info' => 'System/Info',
      'Dashboard' => 'Dashboard',
      'Routing simulation' => 'Routing/RoutingSimulation'
    }.freeze

    # def read?
    #   if Rails.env.development? && SECTION_NAMES.key?(record.name)
    #     logger.warn { "[POLICY WARNING] missing policy for page #{record.name.inspect}" }
    #   end
    #   super
    # end

    private

    def section_name
      SECTION_NAMES.fetch(record.name, record.name).to_sym
    end
  end
end
