# frozen_string_literal: true

# == Schema Information
#
# Table name: external_data.countries
#
#  id   :integer(4)       not null
#  iso2 :string
#  name :string
#
class Cdr::Country < Cdr::Base
  self.table_name = 'external_data.countries'
end
