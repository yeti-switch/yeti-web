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

class System::Country < ApplicationRecord
  self.table_name = 'sys.countries'
  has_many :prefixes, class_name: 'System::NetworkPrefix'
  has_many :networks, -> { distinct }, through: :prefixes

  validates :name, presence: true, uniqueness: true

  scope :search_for, ->(term) { where("countries.name || ' | ' || countries.id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }

  def display_name
    "#{name} | #{id}"
  end

  def self.collection
    order(:name)
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      search_for ordered_by
    ]
  end
end
