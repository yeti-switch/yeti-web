# frozen_string_literal: true

# == Schema Information
#
# Table name: gui.oauth_openid_requests
# Database name: primary
#
#  id              :bigint(8)        not null, primary key
#  nonce           :string           not null
#  access_grant_id :bigint(8)        not null
#
# Indexes
#
#  index_oauth_openid_requests_on_access_grant_id  (access_grant_id)
#
# Foreign Keys
#
#  oauth_openid_requests_access_grant_id_fkey  (access_grant_id => oauth_access_grants.id) ON DELETE => cascade
#
class OauthOpenidRequest < ApplicationRecord
  include ::Doorkeeper::OpenidConnect::Orm::ActiveRecord::Mixins::OpenidRequest
  # The mixin assigns table_name itself, so this override has to come after the
  # include — same as the other gui-schema OAuth models.
  self.table_name = 'gui.oauth_openid_requests'
end
