class Ability
  # include CanCan::Ability

  def initialize(user)

    user ||= AdminUser.new

    can :manage, :all
    can :change_state, :all
    cannot [:change_state, :create, :update], AdminUser

    can :update, AdminUser do |other_user|
      other_user.id == user.id || user.root?
    end

    can :create, AdminUser if user.root?
    can :change_state , AdminUser do |other_user|
         #can't deactivate root user
         user.root? and other_user.root? == false
    end



    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
