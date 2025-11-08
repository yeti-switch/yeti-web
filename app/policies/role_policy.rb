# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  DEFAULT_SECTION = :Default

  class_attribute :_section_name, instance_writer: false
  class_attribute :root_role, instance_writer: false
  class_attribute :allowed_actions, instance_writer: false, default: %i[read change remove perform details rollback batch_update batch_destroy]
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

  def batch_update?
    allowed_for_role?(:batch_update)
  end

  def batch_destroy?
    allowed_for_role?(:batch_destroy)
  end

  alias_rule :import?, to: :perform? # ActiveAdminImport::Auth::IMPORT
  alias_rule :do_import?, to: :import? # active_admin_import

  alias_rule :batch_insert?, :batch_replace?, :delete_all?,
             to: :perform?

  private

  # action could be one of [:read, :change, :remove, :perform]
  def allowed_for_role?(action)
    return true if user_root?
    raise ArgumentError, "#{action} is not one of #{allowed_actions}" if allowed_actions.exclude?(action)

    if ENV['DEBUG_POLICY_ACTION'] === action.to_s && roles_config.nil? && YetiConfig.role_policy.when_no_config.to_sym === :allow
      logger.debug { "[POLICY] policy class for #{self.class.name}. is allowed '#{action}', based on 'role_policy.when_no_config == allow' config" }
    end

    if ENV['DEBUG_POLICY_ACTION'] === action.to_s && roles_config.nil? && YetiConfig.role_policy.when_no_config.to_sym === :disallow
      logger.debug { "[POLICY] policy class for #{self.class.name}. is NOT allowed '#{action}', based on 'role_policy.when_no_config == disallow' config" }
    end

    return allow_when_no_config? if roles_config.nil?

    user_roles.any? { |role| allowed?(role, action) }
  end

  def allowed?(role, action)
    return false unless roles_config.key?(role)

    role_policy = roles_config[role]
    if role_policy.key?(section_name) && role_policy[section_name].key?(action)
      result = role_policy[section_name][action]
      if ENV['DEBUG_POLICY_ACTION'] === action.to_s && result
        logger.debug { "[POLICY] #{role} role, policy class for #{self.class.name}. Allowed '#{action}', based on '#{section_name}' section name" }
      end
      if ENV['DEBUG_POLICY_ACTION'] === action.to_s && !result
        logger.debug { "[POLICY] #{role} role, policy class for #{self.class.name}. NOT allowed '#{action}', based on '#{section_name}' section name" }
      end

      result
    else
      result = role_policy.dig(DEFAULT_SECTION, action)
      if ENV['DEBUG_POLICY_ACTION'] === action.to_s && !result
        logger.debug { "[POLICY] #{role} role, policy class for #{self.class.name}. NOT allowed '#{action}', base on absence it within 'Default' section name" }
      end

      if ENV['DEBUG_POLICY_ACTION'] === action.to_s && result
        logger.debug { "[POLICY] #{role} role, policy class for #{self.class.name}. Allowed '#{action}', base on 'Default' section name" }
      end

      result || false
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
