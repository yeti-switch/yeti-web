# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.customers_auth_dst_number_fields
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  customers_auth_dst_number_fields_name_key  (name) UNIQUE
#
class Routing::CustomerAuthDstNumberField < ApplicationRecord
  self.table_name = 'class4.customers_auth_dst_number_fields'

  validates :name, presence: true, uniqueness: true

  def display_name
    name.to_s
  end
end
