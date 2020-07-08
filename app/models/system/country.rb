# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.countries
#
#  id   :integer(4)       not null, primary key
#  iso2 :string(2)        not null
#  name :string           not null
#
# Indexes
#
#  countries_name_key  (name) UNIQUE
#

class System::Country < Yeti::ActiveRecord
  self.table_name = 'sys.countries'
  has_many :prefixes, class_name: 'System::NetworkPrefix'
  has_many :networks, -> { distinct }, through: :prefixes

  def display_name
    "#{id} | #{name}"
  end

  def self.collection
    order(:name)
  end
end
