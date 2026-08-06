# frozen_string_literal: true

class OauthApplicationPolicy < ::RolePolicy
  alias_rule :rotate_secret?, to: :perform?

  private

  def section_name
    :'System/OauthApplication'
  end
end
