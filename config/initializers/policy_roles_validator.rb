# frozen_string_literal: true

require 'yaml'

# Validate policy_roles.yml during Rails initialization
config_file_path = Rails.root.join('config/policy_roles.yml')

if File.exist?(config_file_path)
  policy_roles = YAML.load_file(config_file_path)

  policy_roles.each do |role, permissions|
    next unless permissions.dig('Dashboard', 'read') == false

    Rails.logger.warn <<~WARNING

  +--------------------------------------------+
  | ⚠️      Invalid Dashboard permission        |
  +--------------------------------------------+

  Role: #{role}
  File: config/policy_roles.yml

   The invalid configuration:

    Dashboard:
      read: false

   ❌ This disables the Dashboard in an unsupported way.

   ✅ Recommended configuration:

    Dashboard:
      read: true
      details: false

   This ensures the Dashboard loads, but its content remain restricted.

    WARNING
    break
  end
end
