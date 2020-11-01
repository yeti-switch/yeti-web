# frozen_string_literal: true

# == Schema Information
#
# Table name: import_rate_groups
#
#  id           :bigint(8)        not null, primary key
#  error_string :string
#  is_changed   :boolean
#  name         :string
#  o_id         :integer(4)
#

class Importing::RateGroup < Importing::Base
  self.table_name = 'import_rate_groups'

  self.import_attributes = %w[name]

  import_for Routing::RateGroup
end
