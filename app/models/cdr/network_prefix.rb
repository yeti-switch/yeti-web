# frozen_string_literal: true

# == Schema Information
#
# Table name: external_data.network_prefixes
#
#  id                :integer(4)       not null, primary key
#  number_max_length :integer(4)
#  number_min_length :integer(4)
#  prefix            :string
#  uuid              :uuid
#  country_id        :integer(4)
#  network_id        :integer(4)
#
class Cdr::NetworkPrefix < Cdr::Base
  self.table_name = 'external_data.network_prefixes'
end
