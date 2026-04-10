# frozen_string_literal: true

oidc_config_path = Rails.root.join('config/oidc.yml')

if File.exist?(oidc_config_path)
  oidc_yaml = YAML.load_file(oidc_config_path, aliases: true)[Rails.env] || {}

  ActiveAdmin::Oidc.configure do |c|
    c.issuer        = oidc_yaml.fetch('issuer')
    c.client_id     = oidc_yaml.fetch('client_id')
    c.client_secret = oidc_yaml['client_secret'].presence
    c.scope         = oidc_yaml['scope'] if oidc_yaml['scope'].present?

    c.identity_attribute = :username
    c.identity_claim     = (oidc_yaml['identity_claim'] || 'preferred_username').to_sym

    default_roles = Array(oidc_yaml['default_roles'])
    roles_claim   = oidc_yaml['roles_claim'] || 'roles'

    c.on_login = lambda do |admin_user, claims|
      raw_roles = claims[roles_claim]
      claimed_roles = case raw_roles
                      when Hash
                        # Zitadel shape: { "role-name" => { "org-id" => "org-name" } }
                        raw_roles.keys
                      else
                        Array.wrap(raw_roles)
                      end.reject(&:blank?).map(&:to_s)

      # Only yeti-web roles defined in config/policy_roles.yml are meaningful;
      # anything else would make Pundit deny every page and land the user in
      # a redirect loop. Intersect the IdP-provided roles with the configured
      # set; if that's empty, try default_roles from oidc.yml; if *that* is
      # also empty (or misconfigured), deny the login.
      supported = AdminUser.available_roles.map(&:to_s)
      accepted  = claimed_roles & supported
      accepted  = default_roles.map(&:to_s) & supported if accepted.empty?

      if accepted.empty?
        Rails.logger.warn(
          "[activeadmin-oidc] login denied for #{claims['sub'].inspect}: " \
          "no supported role in claim #{claimed_roles.inspect} nor " \
          "default_roles #{default_roles.inspect} " \
          "(available: #{supported.inspect})"
        )
        return false
      end

      # Block disabled users — Devise checks active_for_authentication?
      # only on session deserialization, not on initial OmniAuth sign-in.
      return false if admin_user.persisted? && !admin_user.enabled?

      admin_user.roles = accepted
      admin_user.email = claims['email'] if claims['email'].present?
      admin_user.enabled = true if admin_user.new_record?
      true
    end
  end
end
