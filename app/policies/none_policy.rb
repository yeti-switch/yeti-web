class NonePolicy < ApplicationPolicy

  def read?
    default_policy!
  end

  def create?
    default_policy!
  end

  def update?
    default_policy!
  end

  def destroy?
    default_policy!
  end

  private

  def default_policy!
    record_class = record.is_a?(Class) ? record : record.class
    rule = Rails.configuration.yeti_web['role_policy']['when_no_policy_class']
    # if Rails.env.development? && ENV['CREATE_ROLE_MISSING_POLICY']
    #   logger.debug { "[POLICY DEBUG] create missing policy class for #{record_class}." }
    #   Rails::Generators.invoke 'role_policy', [record_class.to_s] # `rails g role_policy #{record_class}`
    # end
    case rule.to_sym
    when :allow then
      logger.warn { "[POLICY WARNING] missing policy class for #{record_class}." }
      true
    when :disallow then
      logger.warn { "[POLICY WARNING] missing policy class for #{record_class}." }
      false
    when :raise then
      raise StandardError, "missing policy class for #{record_class}."
    end
  end

end
