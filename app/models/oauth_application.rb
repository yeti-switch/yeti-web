# frozen_string_literal: true

# == Schema Information
#
# Table name: gui.oauth_applications
#
#  id           :bigint(8)        not null, primary key
#  confidential :boolean          default(TRUE), not null
#  name         :string           not null
#  redirect_uri :text             not null
#  scopes       :string           default(""), not null
#  secret       :string           not null
#  uid          :string           not null
#  created_at   :timestamptz      not null
#  updated_at   :timestamptz      not null
#
# Indexes
#
#  index_oauth_applications_on_uid  (uid) UNIQUE
#
class OauthApplication < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  self.table_name = 'gui.oauth_applications'

  # Shown wherever ActiveAdmin auto-renders the record (e.g. the OAuth Access
  # Tokens page's Application column). Includes the client UID so it's
  # identifiable even when two clients register the same name.
  def display_name
    "#{name} (#{uid})"
  end
end
