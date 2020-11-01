# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.rate_groups
#
#  id          :integer(4)       not null, primary key
#  name        :string           not null
#  external_id :bigint(8)
#
# Indexes
#
#  rate_groups_external_id_key  (external_id) UNIQUE
#  rate_groups_name_key         (name) UNIQUE
#
class Routing::RateGroup < ActiveRecord::Base
  self.table_name = 'class4.rate_groups'
  before_destroy :check_deps

  has_and_belongs_to_many :rateplans, class_name: 'Routing::Rateplan',
                                      join_table: 'class4.rate_plan_groups'

  has_many :destinations, dependent: :destroy

  has_paper_trail class_name: 'AuditLogItem'

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }
  validates :external_id, uniqueness: { allow_blank: true }

  def display_name
    "#{name} | #{id}"
  end

  private

  def check_deps
    if rateplans.count > 0
      errors.add(:base, 'Rate Group used in Rate Plan configuration. You must unlink it first')
      throw(:abort)
    end
  end
end
