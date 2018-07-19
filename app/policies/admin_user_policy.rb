class AdminUserPolicy < RolePolicy
  class Scope < RolePolicy::Scope
  end

  # cannot [:change_state, :create, :update], AdminUser
  #
  # can :update, AdminUser do |other_user|
  #   other_user.id == user.id || user.root?
  # end
  #
  # can :create, AdminUser if user.root?
  #
  # can :change_state , AdminUser do |other_user|
  #   #can't deactivate root user
  #   user.root? and other_user.root? == false
  # end
  #
  # def perform?
  #   if user.id != record.id && record.root?
  #     false
  #   else
  #     super
  #   end
  # end

  alias_rule :enabled?, :disabled?, to: :perform? # DSL acts_as_status

  private

  def section_name
    if user.id == record.id
      :'System/AdminUser/Self'
    else
      :'System/AdminUser'
    end
  end
end
