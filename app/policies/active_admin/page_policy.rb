module ActiveAdmin
  class PagePolicy < ::RolePolicy
    class Scope < RolePolicy::Scope
    end

    SECTION_NAMES = {
        'Info'.freeze => 'System/Info'.freeze
    }.freeze

    private

    def section_name
      SECTION_NAMES.fetch(record.name, record.name).to_sym
    end
  end
end
