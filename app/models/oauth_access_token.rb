# frozen_string_literal: true

# == Schema Information
#
# Table name: gui.oauth_access_tokens
#
#  id                     :bigint(8)        not null, primary key
#  expires_in             :integer(4)
#  previous_refresh_token :string           default(""), not null
#  refresh_token          :string
#  revoked_at             :timestamptz
#  scopes                 :string
#  token                  :string           not null
#  created_at             :timestamptz      not null
#  application_id         :bigint(8)        not null
#  resource_owner_id      :bigint(8)
#
# Indexes
#
#  index_oauth_access_tokens_on_application_id     (application_id)
#  index_oauth_access_tokens_on_refresh_token      (refresh_token) UNIQUE
#  index_oauth_access_tokens_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_tokens_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  oauth_access_tokens_application_id_fkey     (application_id => oauth_applications.id)
#  oauth_access_tokens_resource_owner_id_fkey  (resource_owner_id => admin_users.id) ON DELETE => cascade
#
class OauthAccessToken < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken
  self.table_name = 'gui.oauth_access_tokens'
end
