# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.projects
#
#  id                           :integer(4)       not null, primary key
#  acd_limit                    :float            default(0.0)
#  asr_limit                    :float            default(0.0)
#  capacity                     :integer(2)
#  dst_number_max_length        :integer(2)       default(100), not null
#  dst_number_min_length        :integer(2)       default(0), not null
#  dst_rewrite_result           :string
#  dst_rewrite_rule             :string
#  enabled                      :boolean          default(TRUE), not null
#  exclusive_route              :boolean          default(FALSE), not null
#  force_hit_rate               :float
#  initial_interval             :integer(4)       default(1)
#  keep_applied_pricelists_days :integer(2)       default(30), not null
#  lcr_rate_multiplier          :decimal(, )      default(1.0)
#  name                         :string           not null
#  next_interval                :integer(4)       default(1)
#  priority                     :integer(4)       default(100), not null
#  reverse_billing              :boolean          default(FALSE)
#  routing_tag_ids              :integer(2)       default([]), not null, is an Array
#  short_calls_limit            :float            default(1.0), not null
#  src_name_rewrite_result      :string
#  src_name_rewrite_rule        :string
#  src_rewrite_result           :string
#  src_rewrite_rule             :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  account_id                   :integer(4)       not null
#  gateway_group_id             :integer(4)
#  gateway_id                   :integer(4)
#  routeset_discriminator_id    :integer(2)       not null
#  routing_group_id             :integer(4)       not null
#  routing_tag_mode_id          :integer(2)       default(0)
#  vendor_id                    :integer(4)       not null
#
# Indexes
#
#  index_ratemanagement.projects_on_account_id                 (account_id)
#  index_ratemanagement.projects_on_gateway_group_id           (gateway_group_id)
#  index_ratemanagement.projects_on_gateway_id                 (gateway_id)
#  index_ratemanagement.projects_on_name                       (name) UNIQUE
#  index_ratemanagement.projects_on_routeset_discriminator_id  (routeset_discriminator_id)
#  index_ratemanagement.projects_on_routing_group_id           (routing_group_id)
#  index_ratemanagement.projects_on_routing_tag_mode_id        (routing_tag_mode_id)
#  index_ratemanagement.projects_on_vendor_id                  (vendor_id)
#
# Foreign Keys
#
#  fk_rails_2016c4d0a1  (routing_group_id => routing_groups.id)
#  fk_rails_8c0fbee7b0  (routing_tag_mode_id => routing_tag_modes.id)
#  fk_rails_9da44a0caf  (gateway_group_id => gateway_groups.id)
#  fk_rails_ab15e0e646  (gateway_id => gateways.id)
#  fk_rails_bba2bcfb14  (account_id => accounts.id)
#  fk_rails_ca9d46244c  (routeset_discriminator_id => routeset_discriminators.id)
#  fk_rails_ce692652ea  (vendor_id => contractors.id)
#
module RateManagement
  class Project < ApplicationRecord
    self.table_name = 'ratemanagement.projects'

    include WithPaperTrail
    MIN_KEEP_APPLIED_PRICELISTS_DAYS = 0
    MAX_KEEP_APPLIED_PRICELISTS_DAYS = 365

    attribute :enabled, :boolean, default: true

    belongs_to :gateway, optional: true
    belongs_to :gateway_group, optional: true
    belongs_to :routing_group, class_name: 'Routing::RoutingGroup'
    belongs_to :account
    belongs_to :vendor, class_name: 'Contractor'
    belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode', optional: true
    belongs_to :routeset_discriminator, class_name: 'Routing::RoutesetDiscriminator'
    array_belongs_to :routing_tags, class_name: 'Routing::RoutingTag', foreign_key: :routing_tag_ids
    has_many :pricelists, class_name: 'RateManagement::Pricelist', dependent: :restrict_with_error

    before_save do
      self.routing_tag_ids = RoutingTagsSort.call(routing_tag_ids)
    end

    validates :name, presence: true
    validates :enabled, :exclusive_route, inclusion: { in: [true, false] }
    validates :name, uniqueness: true, allow_nil: true
    validates :initial_interval, :next_interval, numericality: { greater_than: 0, allow_nil: true }
    validates :acd_limit, numericality: {
      greater_than_or_equal_to: 0.00,
      allow_nil: true
    }
    validates :asr_limit, numericality: {
      greater_than_or_equal_to: 0.00,
      less_than_or_equal_to: 1.00,
      allow_nil: true
    }
    validates :short_calls_limit, presence: true
    validates :short_calls_limit, numericality: {
      greater_than_or_equal_to: 0.00,
      less_than_or_equal_to: 1.00,
      allow_nil: true
    }
    validates :force_hit_rate, numericality: {
      greater_than_or_equal_to: 0.00,
      less_than_or_equal_to: 1.00,
      allow_nil: true
    }
    validates :capacity, numericality: {
      greater_than: 0,
      less_than_or_equal_to: PG_MAX_SMALLINT,
      allow_nil: true,
      only_integer: true
    }
    validates :dst_number_min_length, presence: true
    validates :dst_number_min_length, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100,
      only_integer: true,
      allow_nil: true
    }
    validates :dst_number_max_length, presence: true
    validates :dst_number_max_length, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100,
      only_integer: true,
      allow_nil: true
    }
    validates :keep_applied_pricelists_days, presence: true
    validates :keep_applied_pricelists_days, allow_nil: true, numericality: {
      greater_than_or_equal_to: MIN_KEEP_APPLIED_PRICELISTS_DAYS,
      less_than_or_equal_to: MAX_KEEP_APPLIED_PRICELISTS_DAYS
    }
    validates :priority, presence: true
    validates :priority, numericality: {
      only_integer: true,
      greater_than_or_equal_to: -PG_MAX_INT,
      less_than_or_equal_to: PG_MAX_INT,
      allow_nil: true
    }

    validate :contractor_is_vendor, if: :vendor
    validate :vendor_owners_the_account, if: -> { vendor && account }
    validate :vendor_owners_the_gateway, if: -> { vendor && gateway }
    validate :vendor_owners_the_gateway_group, if: -> { vendor && gateway_group }
    validate :validate_gateway_gateway_group_presence
    validate :validate_project_with_same_scope

    validates_with RoutingTagIdsValidator

    scope :ordered, -> { order(name: :asc) }

    def display_name
      "#{name} | #{id}"
    end

    private

    def contractor_is_vendor
      errors.add(:vendor, 'Is not vendor') unless vendor.vendor
    end

    def vendor_owners_the_account
      errors.add(:account, 'must be owned by selected vendor') unless vendor_id == account.contractor_id
    end

    def vendor_owners_the_gateway
      return true if gateway.is_shared?

      errors.add(:gateway, 'must be owned by selected vendor or be shared') unless vendor_id == gateway.contractor_id

      errors.add(:gateway, 'must be allowed for termination') unless gateway.allow_termination
    end

    def vendor_owners_the_gateway_group
      errors.add(:gateway_group, 'must be owned by selected vendor') unless vendor_id == gateway_group.vendor_id
    end

    def validate_gateway_gateway_group_presence
      errors.add(:base, 'specify a gateway_group or a gateway') if gateway.nil? && gateway_group.nil?
      errors.add(:base, "both gateway and gateway_group can't be set in a same time") if gateway && gateway_group
    end

    def validate_project_with_same_scope
      scope = RateManagement::Project.where(
        account_id: account_id,
        vendor_id: vendor_id,
        routing_group_id: routing_group_id,
        routeset_discriminator_id: routeset_discriminator_id
      )
      scope = scope.where.not(id: id) if persisted?
      errors.add(:base, 'Project with same scope attributes already exists') if scope.exists?
    end
  end
end
