# == Schema Information
#
# Table name: class4.customers_auth
#
#  id                               :integer          not null, primary key
#  customer_id                      :integer          not null
#  rateplan_id                      :integer          not null
#  enabled                          :boolean          default(TRUE), not null
#  account_id                       :integer
#  gateway_id                       :integer          not null
#  src_rewrite_rule                 :string
#  src_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  dst_rewrite_result               :string
#  name                             :string           not null
#  dump_level_id                    :integer          default(0), not null
#  capacity                         :integer
#  pop_id                           :integer
#  src_name_rewrite_rule            :string
#  src_name_rewrite_result          :string
#  diversion_policy_id              :integer          default(1), not null
#  diversion_rewrite_rule           :string
#  diversion_rewrite_result         :string
#  dst_numberlist_id                :integer
#  src_numberlist_id                :integer
#  routing_plan_id                  :integer          not null
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  radius_auth_profile_id           :integer
#  enable_audio_recording           :boolean          default(FALSE), not null
#  src_number_radius_rewrite_rule   :string
#  src_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_number_radius_rewrite_result :string
#  radius_accounting_profile_id     :integer
#  transport_protocol_id            :integer
#  dst_number_max_length            :integer          default(100), not null
#  check_account_balance            :boolean          default(TRUE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  tag_action_id                    :integer
#  tag_action_value                 :integer          default([]), not null, is an Array
#  dst_number_min_length            :integer          default(0), not null
#  ip                               :inet             default(["\"127.0.0.0/8\""]), is an Array
#  src_prefix                       :string           default(["\"\""]), is an Array
#  dst_prefix                       :string           default(["\"\""]), is an Array
#  uri_domain                       :string           default([]), is an Array
#  from_domain                      :string           default([]), is an Array
#  to_domain                        :string           default([]), is an Array
#  x_yeti_auth                      :string           default([]), is an Array
#  external_id                      :integer
#

class CustomersAuth < Yeti::ActiveRecord
  self.table_name = 'class4.customers_auth'

  module CONST
    MATCH_CONDITION_ATTRIBUTES = [:ip,
                                  :src_prefix,
                                  :dst_prefix,
                                  :uri_domain,
                                  :from_domain,
                                  :to_domain,
                                  :x_yeti_auth].freeze

    freeze
  end

  belongs_to :customer, -> { where customer: true }, class_name: 'Contractor', foreign_key: :customer_id

  belongs_to :rateplan
  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan'
  belongs_to :gateway
  belongs_to :account
  belongs_to :dump_level
  belongs_to :pop
  belongs_to :diversion_policy
  belongs_to :dst_numberlist, class_name: Routing::Numberlist, foreign_key: :dst_numberlist_id
  belongs_to :src_numberlist, class_name: Routing::Numberlist, foreign_key: :src_numberlist_id
  belongs_to :radius_auth_profile, class_name: Equipment::Radius::AuthProfile, foreign_key: :radius_auth_profile_id
  belongs_to :radius_accounting_profile, class_name: Equipment::Radius::AccountingProfile, foreign_key: :radius_accounting_profile_id
  belongs_to :transport_protocol, class_name: Equipment::TransportProtocol, foreign_key: :transport_protocol_id

  belongs_to :tag_action, class_name: 'Routing::TagAction'

  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  has_many :destinations, through: :rateplan
  has_many :normalized_copies, class_name: 'CustomersAuthNormalized', foreign_key: :customers_auth_id, dependent: :delete_all

  has_paper_trail class_name: 'AuditLogItem'

  # REDIRECT_METHODS = [
  #     301,
  #     302
  # ]

  validates :ip, :src_prefix, :dst_prefix, :uri_domain, :from_domain, :to_domain, :x_yeti_auth,
            array_format: { without: /\s/, message: 'spaces are not allowed' }

  validates :ip, :src_prefix, :dst_prefix, :uri_domain, :from_domain, :to_domain, :x_yeti_auth,
            array_uniqueness: true

  validates_presence_of :ip


  validates_uniqueness_of :name, allow_blank: :false
  validates_presence_of :name
  validates_uniqueness_of :external_id, allow_blank: true

  validates_presence_of :customer, :rateplan, :routing_plan, :gateway, :account, :dump_level, :diversion_policy

  validates_presence_of :dst_number_min_length, :dst_number_max_length
  validates_numericality_of :dst_number_min_length, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true
  validates_numericality_of :dst_number_max_length, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true

  validates_numericality_of :capacity, greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true

  validate :ip_is_valid
  validate :gateway_supports_incoming_auth

  validates_with TagActionValueValidator

  scope :with_radius, -> { where("radius_auth_profile_id is not null") }
  scope :with_dump, -> { where("dump_level_id > 0") }
  scope :ip_covers, ->(ip) do
    IPAddr.new(ip) rescue return none
    where(
      "#{self.table_name}.id IN (
        SELECT customers_auth_id FROM #{CustomersAuthNormalized.table_name} WHERE ip>>='#{ip}'::inet
      )"
    )
  end

  include Yeti::ResourceStatus

  include PgEvent
  has_pg_queue 'gateway-sync'


  after_create :create_shadow_copy
  after_update :update_shadow_copy

  def display_name
    "#{self.name} | #{self.id}"
  end

  # TODO: move to decorator when ActiveAdmin fix problem
  # Problem is:
  # on "update" AA uses decorated object
  # on "create" AA do NOT use decorated object
  CONST::MATCH_CONDITION_ATTRIBUTES.each do |attribute_name|
    define_method "#{attribute_name}=" do |value|
      if value.is_a? String
        value = value.split(',').map(&:strip).reject(&:blank?)
      end
      super(value)
    end
  end


  def display_name_for_debug
    b="#{self.customer.display_name} -> #{self.name} | #{self.id} IP: #{self.raw_ip}"
    if !self.uri_domain.blank?
      b=b+", Domain: #{self.uri_domain}"
    end
    if !self.pop_id.nil?
      b=b+", POP: #{self.pop.try(:name)}"
    end
    if !self.x_yeti_auth.blank?
      b=b+", X-Yeti-Auth: #{self.x_yeti_auth}"
    end
    b
  end

  # def pop_name
  #   pop.nil? ? "Any" : pop.name
  # end

  def self.search_for_debug(src, dst)
    if src.blank?&&dst.blank?
      CustomersAuth.all.reorder(:name)
    elsif src.blank?
      CustomersAuth.where("prefix_range(customers_auth.dst_prefix)@>prefix_range(?)", dst).reorder(:name)
    elsif dst.blank?
      CustomersAuth.where("prefix_range(customers_auth.src_prefix)@>prefix_range(?)", src).reorder(:name)
    else
      CustomersAuth.where("prefix_range(customers_auth.src_prefix)@>prefix_range(?) AND
  prefix_range(customers_auth.dst_prefix)@>prefix_range(?)", src, dst).reorder(:name)
    end
  end

  #force update IP
  def keys_for_partial_write
    (changed + ['ip']).uniq
  end

  private

  def self.ransackable_scopes(auth_object = nil)
    [:ip_covers]
  end

  protected
  def ip_is_valid
    begin
      ip.each do |raw_ip|
        _tmp = IPAddr.new(raw_ip)
      end if ip.is_a? Array
    rescue IPAddr::Error => error
      self.errors.add(:ip, "is not valid")
    end
  end

  def gateway_supports_incoming_auth
    if self.gateway.try(:incoming_auth_username).blank? and self.require_incoming_auth
      self.errors.add(:gateway, I18n.t('activerecord.errors.models.customers_auth.attributes.gateway.incoming_auth_required'))
      self.errors.add(:require_incoming_auth, I18n.t('activerecord.errors.models.customers_auth.attributes.require_incoming_auth.gateway_with_auth_reqired'))
    end
  end

  def create_shadow_copy
    copy_attributes = { customers_auth_id: id }

    # all other attributes
    CustomersAuthNormalized.shadow_column_names.each do |key|
      copy_attributes[key] = self.public_send(key)
    end

    if match_conditions_values.empty?
      CustomersAuthNormalized.create!(copy_attributes)
    end

    match_conditions_values.each do |match_conditions_pair|
      # match_conditions attirbutes
      match_conditions_pair.each do |pair|
        key, value = pair.flatten
        copy_attributes[key] = value
      end
      CustomersAuthNormalized.create!(copy_attributes)
    end
  end

  def update_shadow_copy
    # keep it simple: delete all and create again
    normalized_copies.delete_all
    create_shadow_copy
  end

  def match_conditions_values
    @_mcv = begin
              ar_values = CONST::MATCH_CONDITION_ATTRIBUTES.map do |mc_name|
                self.public_send(mc_name).map { |v| { mc_name => v } }
              end.reject(&:empty?)
              return [] if ar_values.empty?
              first_arr = ar_values.shift
              first_arr.product(*ar_values)
            end
  end
end

