# frozen_string_literal: true

# Policy for the AA "OAuth Applications" page — the registered OAuth/OIDC
# clients. Page-level access is governed by role config like any other admin
# page (config/policy_roles.yml, section "System/OauthApplication"): `read`
# controls who sees the page, `change` who can register or edit a client,
# `remove` who can delete one, and `perform` who can rotate a client secret.
#
# `read` is more sensitive here than on most pages: the show page displays the
# client secret, because Doorkeeper stores it in cleartext (hash_application_secrets
# is off) and an operator wiring up a client needs to read it back.
class OauthApplicationPolicy < ::RolePolicy
  alias_rule :rotate_secret?, to: :perform?

  private

  def section_name
    :'System/OauthApplication'
  end
end
