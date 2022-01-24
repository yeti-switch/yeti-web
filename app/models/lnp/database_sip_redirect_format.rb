# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_30x_redirect_formats
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  lnp_databases_30x_redirect_formats_name_key  (name) UNIQUE
#
class Lnp::DatabaseSipRedirectFormat < ApplicationRecord
  self.table_name = 'class4.lnp_databases_30x_redirect_formats'

  validates :name, uniqueness: true, presence: true
end
