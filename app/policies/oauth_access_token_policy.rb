# frozen_string_literal: true

# Policy for the AA "Authorized Applications" page. Owner-scoped by default:
# any admin can read / revoke their own access tokens, root sees and revokes
# everything. The policy scope hides other users' tokens at the query level.
class OauthAccessTokenPolicy < ::RolePolicy
  class Scope < ::ApplicationPolicy::Scope
    def resolve
      return scope.all if user_root?

      scope.where(resource_owner_id: user.id)
    end

    private

    def user_root?
      user && ::RolePolicy.root_role && user.roles.reject(&:blank?).map(&:to_sym).include?(::RolePolicy.root_role)
    end
  end

  def read?
    myself? || super
  end

  def destroy?
    myself? || super
  end

  private

  def myself?
    record.is_a?(::OauthAccessToken) && record.resource_owner_id == user&.id
  end

  def section_name
    :'System/AuthorizedApplication'
  end
end
