# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.pricelist_items
#
#  id                        :bigint(8)        not null, primary key
#  acd_limit                 :float
#  asr_limit                 :float
#  capacity                  :integer(2)
#  connect_fee               :decimal(, )      not null
#  detected_dialpeer_ids     :bigint(8)        default([]), is an Array
#  dst_number_max_length     :integer(2)       not null
#  dst_number_min_length     :integer(2)       not null
#  dst_rewrite_result        :string
#  dst_rewrite_rule          :string
#  enabled                   :boolean
#  exclusive_route           :boolean          not null
#  force_hit_rate            :float
#  initial_interval          :integer(2)       not null
#  initial_rate              :decimal(, )      not null
#  lcr_rate_multiplier       :decimal(, )
#  next_interval             :integer(2)       not null
#  next_rate                 :decimal(, )      not null
#  prefix                    :string           default(""), not null
#  priority                  :integer(4)
#  reverse_billing           :boolean          default(FALSE)
#  routing_tag_ids           :integer(2)       default([]), not null, is an Array
#  short_calls_limit         :float            not null
#  src_name_rewrite_result   :string
#  src_name_rewrite_rule     :string
#  src_rewrite_result        :string
#  src_rewrite_rule          :string
#  to_delete                 :boolean          default(FALSE), not null
#  valid_from                :datetime
#  valid_till                :datetime         not null
#  account_id                :integer(4)
#  dialpeer_id               :bigint(8)
#  gateway_group_id          :integer(4)
#  gateway_id                :integer(4)
#  pricelist_id              :integer(4)       not null
#  routeset_discriminator_id :integer(2)
#  routing_group_id          :integer(4)
#  routing_tag_mode_id       :integer(2)       default(0)
#  vendor_id                 :integer(4)
#
# Indexes
#
#  index_ratemanagement.pricelist_items_on_account_id               (account_id)
#  index_ratemanagement.pricelist_items_on_dialpeer_id              (dialpeer_id)
#  index_ratemanagement.pricelist_items_on_gateway_group_id         (gateway_group_id)
#  index_ratemanagement.pricelist_items_on_gateway_id               (gateway_id)
#  index_ratemanagement.pricelist_items_on_pricelist_id             (pricelist_id)
#  index_ratemanagement.pricelist_items_on_routing_group_id         (routing_group_id)
#  index_ratemanagement.pricelist_items_on_routing_tag_mode_id      (routing_tag_mode_id)
#  index_ratemanagement.pricelist_items_on_vendor_id                (vendor_id)
#  index_ratemanagement.pricelistitems_on_routesetdiscriminator_id  (routeset_discriminator_id)
#
# Foreign Keys
#
#  fk_rails_161e735c3a  (routing_tag_mode_id => routing_tag_modes.id)
#  fk_rails_2bccc045c8  (pricelist_id => ratemanagement.pricelists.id)
#  fk_rails_2f466a9c79  (routeset_discriminator_id => routeset_discriminators.id)
#  fk_rails_5952853742  (routing_group_id => routing_groups.id)
#  fk_rails_935caa9063  (gateway_group_id => gateway_groups.id)
#  fk_rails_995ef47750  (vendor_id => contractors.id)
#  fk_rails_e6d13b64c3  (dialpeer_id => dialpeers.id)
#  fk_rails_f7be9605b8  (account_id => accounts.id)
#  fk_rails_fc08843331  (gateway_id => gateways.id)
#
module RateManagement
  class PricelistItem < ApplicationRecord
    self.table_name = 'ratemanagement.pricelist_items'

    module CONST
      TYPE_CREATE = :create
      TYPE_CHANGE = :change
      TYPE_DELETE = :delete
      TYPE_ERROR = :error

      freeze
    end

    include RoutingTagIdsScopeable

    validates :valid_till, :initial_rate, :initial_interval, :next_interval, presence: true

    belongs_to :gateway, optional: true
    belongs_to :gateway_group, optional: true
    belongs_to :routing_group, class_name: 'Routing::RoutingGroup', optional: true
    belongs_to :account, optional: true
    belongs_to :vendor, class_name: 'Contractor', optional: true
    belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode'
    belongs_to :pricelist, class_name: 'RateManagement::Pricelist'
    belongs_to :dialpeer, class_name: 'Dialpeer', optional: true
    belongs_to :routeset_discriminator, class_name: 'Routing::RoutesetDiscriminator', optional: true
    array_belongs_to :routing_tags, class_name: 'Routing::RoutingTag', foreign_key: :routing_tag_ids

    validates :initial_rate, :next_rate, numericality: true
    validates :initial_interval, :next_interval, numericality: { greater_than: 0 }

    scope :to_create, -> { where("detected_dialpeer_ids = '{}'") }
    scope :to_change, -> { where('array_length(detected_dialpeer_ids, 1) = 1 AND NOT to_delete') }
    scope :to_delete, -> { where(to_delete: true) }
    scope :with_error, -> { where('array_length(detected_dialpeer_ids, 1) > 1') }
    scope :routing_tag_ids_array_contains, lambda { |*routing_tag_ids|
      where.contains routing_tag_ids: Array(routing_tag_ids)
    }
    scope :applied, -> { joins(:pricelist).where(pricelist: { state_id: RateManagement::PricelistState::CONST::STATE_ID_APPLIED }) }
    scope :not_applied, -> { joins(:pricelist).where.not(pricelist: { state_id: RateManagement::PricelistState::CONST::STATE_ID_APPLIED }) }

    def type
      return nil if pricelist.new?

      return CONST::TYPE_DELETE if to_delete
      return CONST::TYPE_CREATE if detected_dialpeer_ids.empty?
      return CONST::TYPE_CHANGE if detected_dialpeer_ids.size == 1

      CONST::TYPE_ERROR if detected_dialpeer_ids.present? && detected_dialpeer_ids.size > 1
    end

    def self.ransackable_scopes(_auth_object = nil)
      %i[
        routing_tag_ids_array_contains
        routing_tag_ids_covers
        tagged
        routing_tag_ids_count_equals
      ]
    end
  end
end
