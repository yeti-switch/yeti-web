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

  # resource_owner_id is the AdminUser id (single-tenant config — Doorkeeper
  # supports polymorphic owners but we don't use it). Explicit belongs_to so
  # the AA index page can eager-load with `.includes(:resource_owner)` and
  # avoid an N+1 in the Owner column for root admins.
  belongs_to :resource_owner, class_name: 'AdminUser', foreign_key: :resource_owner_id, optional: true
end
