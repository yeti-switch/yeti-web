class ApplicationPolicy
  class_attribute :logger, instance_writer: false
  self.logger = Rails.logger

  class << self
    def alias_rule(*rule_names)
      options = rule_names.extract_options!
      options.assert_valid_keys(:to)
      raise ArgumentError, 'provide at least one rule name' if rule_names.empty?
      raise ArgumentError, 'to key is required' if options[:to].nil?
      rule_names.each do |rule_name|
        define_method(rule_name) do
          public_send(options[:to])
        end
      end
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  alias_rule :index?, :show?, to: :read?
  alias_rule :new?, to: :create?
  alias_rule :edit?, to: :update?
  alias_rule :remove?, :destroy_all?, to: :destroy?
  alias_rule :history?, to: :perform? # DSL acts_as_audit

  def read?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def perform?
    true
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  private

  def development?
    Rails.env.development?
  end

  def production?
    Rails.env.production?
  end

  def test?
    Rails.env.test?
  end
end
