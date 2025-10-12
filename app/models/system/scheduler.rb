# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.schedulers
#
#  id               :integer(2)       not null, primary key
#  current_state    :boolean
#  enabled          :boolean          default(TRUE), not null
#  name             :string           not null
#  timezone         :string           default("UTC"), not null
#  use_reject_calls :boolean          default(TRUE), not null
#
# Indexes
#
#  schedulers_name_key  (name) UNIQUE
#
class System::Scheduler < ApplicationRecord
  self.table_name = 'sys.schedulers'

  include WithPaperTrail

  validates :name, uniqueness: { allow_blank: true }, presence: true
  validates :timezone, inclusion: { in: Yeti::TimeZoneHelper.all }, allow_nil: false, allow_blank: false

  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: 'scheduler_id', dependent: :nullify
  has_many :destinations, class_name: 'Routing::Destination', foreign_key: 'scheduler_id', dependent: :nullify
  has_many :dialpeers, class_name: 'Dialpeer', foreign_key: 'scheduler_id', dependent: :nullify
  has_many :gateways, class_name: 'Gateway', foreign_key: 'scheduler_id', dependent: :nullify

  has_many :ranges, class_name: 'System::SchedulerRange', inverse_of: :scheduler, dependent: :destroy

  accepts_nested_attributes_for :ranges, allow_destroy: true

  def display_name
    "#{name} | #{id}"
  end

  def check
    if !ranges.current_ranges(timezone).empty?
      block
    else
      unblock
    end
  end

  def block
    transaction do
      lock!
      self.current_state = true
      save!

      if use_reject_calls
        customers_auths.where(reject_calls: false).find_each do |c|
          c.reject_calls = true
          c.enabled = true
          c.save!
        end
        destinations.where(reject_calls: false).update_all(reject_calls: true, enabled: true)
      else
        customers_auths.where(enabled: true).find_each do |c|
          c.reject_calls = false
          c.enabled = false
          c.save!
        end
        destinations.where(enabled: true).update_all(reject_calls: false, enabled: false)
      end

      dialpeers.where(enabled: true).update_all(enabled: false)
      gateways.where(enabled: true).update_all(enabled: false)
    end
  end

  def unblock
    transaction do
      lock!
      self.current_state = false
      save!

      # we can't use update_all there because we have normalized copies
      customers_auths.where(reject_calls: true).find_each do |c|
        c.reject_calls = false
        c.enabled = true
        c.save!
      end

      destinations.where(reject_calls: false).update_all(reject_calls: false, enabled: true)
      dialpeers.where(enabled: false).update_all(enabled: true)
      gateways.where(enabled: false).update_all(enabled: true)
    end
  end
end
