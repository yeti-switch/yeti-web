# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.pricelists
#
#  id                           :integer(4)       not null, primary key
#  applied_at                   :datetime
#  apply_changes_in_progress    :boolean          default(FALSE), not null
#  detect_dialpeers_in_progress :boolean          default(FALSE), not null
#  filename                     :string           not null
#  items_count                  :integer(4)       default(0), not null
#  name                         :string           not null
#  retain_enabled               :boolean          default(FALSE), not null
#  retain_priority              :boolean          default(FALSE), not null
#  valid_from                   :datetime
#  valid_till                   :datetime         not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  project_id                   :integer(4)       not null
#  state_id                     :integer(2)       not null
#
# Indexes
#
#  index_ratemanagement.pricelists_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_bbdbad8a45  (project_id => ratemanagement.projects.id)
#
module RateManagement
  class Pricelist < ApplicationRecord
    self.table_name = 'ratemanagement.pricelists'

    module CONST
      STATE_ID_APPLIED = 10
      STATE_ID_DIALPEERS_DETECTED = 20
      STATE_ID_NEW = 30

      STATE_IDS = {
        STATE_ID_APPLIED => 'Applied',
        STATE_ID_DIALPEERS_DETECTED => 'Dialpeers detected',
        STATE_ID_NEW => 'New'
      }.freeze

      freeze
    end

    belongs_to :project, class_name: 'RateManagement::Project'

    has_many :items, class_name: 'RateManagement::PricelistItem', dependent: :delete_all, inverse_of: 'pricelist'
    # alias for active admin
    alias pricelist_items items

    validates :name, :filename, :project_id, :valid_till, presence: true
    validates :state_id, inclusion: { in: CONST::STATE_IDS.keys }

    scope :in_progress, lambda {
      where state_id: [
        RateManagement::Pricelist::CONST::STATE_ID_NEW,
        RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED
      ]
    }

    scope :applied, lambda {
      where(state_id: RateManagement::Pricelist::CONST::STATE_ID_APPLIED)
    }

    scope :old_applied, lambda {
      applied
        .joins(:project)
        .where(
        "#{table_name}.applied_at < (
          NOW() - (#{RateManagement::Project.table_name}.keep_applied_pricelists_days||' days')::interval
        )"
      )
    }

    def new?
      state_id == RateManagement::Pricelist::CONST::STATE_ID_NEW
    end

    def dialpeers_detected?
      state_id == RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED
    end

    def applied?
      state_id == RateManagement::Pricelist::CONST::STATE_ID_APPLIED
    end

    def state_name
      CONST::STATE_IDS[state_id]
    end
  end
end
