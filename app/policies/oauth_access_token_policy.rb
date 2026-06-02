# frozen_string_literal: true

# Policy for the AA "OAuth Access Tokens" page. Page-level access is governed
# by role config like any other admin page (config/policy_roles.yml, section
# "System/OauthAccessToken"): `read` controls who sees the page, `remove` who
# can revoke. There is no owner scoping — an admin who can see the page sees
# every token, regardless of who granted it.
class OauthAccessTokenPolicy < ::RolePolicy
  private

  def section_name
    :'System/OauthAccessToken'
  end
end
