# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  DEFAULT_SECTION = :Default

  class_attribute :_section_name, instance_writer: false
  class_attribute :root_role, instance_writer: false
  class_attribute :allowed_actions, instance_writer: false, default: %i[read change remove perform details]
  self.root_role = :root

  class << self
    def section(section_name)
      self._section_name = section_name&.to_sym
    end

    private

    def inherited(subclass)
      subclass.section(nil)
    end
  end

  def read?
    allowed_for_role?(:read)
  end

  def create?
    allowed_for_role?(:change)
  end

  def update?
    allowed_for_role?(:change)
  end

  def destroy?
    allowed_for_role?(:remove)
  end

  def perform?
    allowed_for_role?(:perform)
  end

  alias_rule :import?, to: :perform? # ActiveAdminImport::Auth::IMPORT
  alias_rule :do_import?, to: :import? # active_admin_import

  alias_rule :batch_insert?, :batch_replace?, :batch_update?, :delete_all?,
             to: :perform?

  private

  # action could be one of [:read, :change, :remove, :perform]
  def allowed_for_role?(action)
    return true if user_root?
    raise ArgumentError, "#{action} is not one of #{allowed_actions}" if allowed_actions.exclude?(action)
    return allow_when_no_config? if roles_config.nil?

    user_roles.any? { |role| allowed?(role, action) }
  end

  def allowed?(role, action)
    return false unless roles_config.key?(role)

    role_policy = roles_config[role]
    if role_policy.key?(section_name) && role_policy[section_name].key?(action)
      role_policy[section_name][action]
    else
      role_policy.dig(DEFAULT_SECTION, action) || false
    end
  end

  def user_root?
    user && root_role && user.roles.reject(&:blank?).map(&:to_sym).include?(root_role)
  end

  def user_roles
    user.roles.reject(&:blank?).map(&:to_sym)
  end

  def roles_config
    Rails.configuration.policy_roles
  end

  def allow_when_no_config?
    YetiConfig.role_policy.when_no_config.to_sym == :allow
  end

  def section_name
    _section_name || self.class.to_s[0...-6].gsub('::', '/').to_sym
  end
end
