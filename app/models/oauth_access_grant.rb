# frozen_string_literal: true

# == Schema Information
#
# Table name: gui.oauth_access_grants
#
#  id                :bigint(8)        not null, primary key
#  expires_in        :integer(4)       not null
#  redirect_uri      :text             not null
#  revoked_at        :timestamptz
#  scopes            :string           default(""), not null
#  token             :string           not null
#  created_at        :timestamptz      not null
#  application_id    :bigint(8)        not null
#  resource_owner_id :bigint(8)        not null
#
# Indexes
#
#  index_oauth_access_grants_on_application_id     (application_id)
#  index_oauth_access_grants_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_grants_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  oauth_access_grants_application_id_fkey     (application_id => oauth_applications.id)
#  oauth_access_grants_resource_owner_id_fkey  (resource_owner_id => admin_users.id) ON DELETE => cascade
#
class OauthAccessGrant < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessGrant
  self.table_name = 'gui.oauth_access_grants'
end
