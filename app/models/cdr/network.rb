# frozen_string_literal: true

# == Schema Information
#
# Table name: external_data.networks
#
#  id      :integer(4)       not null
#  name    :string
#  uuid    :uuid
#  type_id :integer(4)
#
class Cdr::Network < Cdr::Base
  self.table_name = 'external_data.networks'
end
