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

  # Ownership is the sole criterion — we deliberately bypass the role config
  # so an admin can't see/revoke another admin's tokens just because their
  # role grants generic "read" / "remove" in policy_roles.yml. Only the
  # resource owner OR root role can act.
  def read?
    myself? || user_root?
  end

  def destroy?
    myself? || user_root?
  end

  private

  def myself?
    record.is_a?(::OauthAccessToken) && record.resource_owner_id == user&.id
  end
end
