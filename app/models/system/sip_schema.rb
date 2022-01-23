# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.sip_schemas
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  sip_schemas_name_key  (name) UNIQUE
#

class System::SipSchema < ApplicationRecord
  self.table_name = 'sys.sip_schemas'

  validates :name, presence: true, uniqueness: true
end
