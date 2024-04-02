# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.area_prefixes
#
#  id      :bigint(8)        not null, primary key
#  prefix  :string           not null
#  area_id :integer(4)       not null
#
# Indexes
#
#  area_prefixes_prefix_key  (prefix) UNIQUE
#
# Foreign Keys
#
#  area_prefixes_area_id_fkey  (area_id => areas.id)
#

class Routing::AreaPrefix < ApplicationRecord
  include WithPaperTrail

  self.table_name = 'class4.area_prefixes'

  belongs_to :area, class_name: 'Routing::Area', foreign_key: :area_id

  validates :prefix, uniqueness: true
  validates :prefix, format: { without: /\s/ }
  validates :area, presence: true

  scope :prefix_covers, lambda { |prefix|
    where("prefix_range(prefix) @> prefix_range(?)", prefix)
  }

  def display_name
    "#{prefix} | #{id}"
  end

  private

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      prefix_covers
    ]
  end
end
