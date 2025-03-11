# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr_exports
#
#  id                  :integer(4)       not null, primary key
#  callback_url        :string
#  fields              :string           default([]), not null, is an Array
#  filters             :json             not null
#  rows_count          :integer(4)
#  status              :string           not null
#  time_format         :string           default("with_timezone"), not null
#  type                :string           not null
#  uuid                :uuid             not null
#  created_at          :datetime
#  updated_at          :datetime
#  customer_account_id :integer(4)
#
# Indexes
#
#  index_sys.cdr_exports_on_customer_account_id  (customer_account_id)
#  index_sys.cdr_exports_on_uuid                 (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_e796f29195  (customer_account_id => accounts.id)
#

class CdrExport < ApplicationRecord
  self.table_name = 'cdr_exports'
  self.store_full_sti_class = false

  include Memoizable

  class FiltersModel < JsonAttributeModel
    include WithActiveModelArrayAttribute

    attribute :time_start_gteq, :db_datetime
    attribute :time_start_lteq, :db_datetime
    attribute :time_start_lt, :db_datetime
    attribute :customer_id_eq, :integer
    attribute :customer_external_id_eq, :integer
    attribute :customer_acc_id_eq, :integer
    attribute :customer_acc_external_id_eq, :integer
    attribute :vendor_id_eq, :integer
    attribute :vendor_external_id_eq, :integer
    attribute :vendor_acc_id_eq, :integer
    attribute :vendor_acc_external_id_eq, :integer
    attribute :is_last_cdr_eq, :boolean
    attribute :success_eq, :boolean
    attribute :customer_auth_id_eq, :integer
    attribute :customer_auth_external_id_eq, :integer
    attribute :failed_resource_type_id_eq, :integer
    attribute :src_prefix_in_contains, :string_presence
    attribute :src_prefix_in_eq, :string_presence
    attribute :dst_prefix_in_contains, :string_presence
    attribute :dst_prefix_in_eq, :string_presence
    attribute :src_prefix_routing_contains, :string_presence
    attribute :src_prefix_routing_eq, :string_presence
    attribute :dst_prefix_routing_contains, :string_presence
    attribute :dst_prefix_routing_eq, :string_presence
    attribute :src_prefix_out_contains, :string_presence
    attribute :src_prefix_out_eq, :string_presence
    attribute :dst_prefix_out_contains, :string_presence
    attribute :dst_prefix_out_eq, :string_presence
    attribute :src_country_id_eq, :integer
    attribute :dst_country_id_eq, :integer
    attribute :routing_tag_ids_include, :integer
    attribute :routing_tag_ids_exclude, :integer
    attribute :routing_tag_ids_empty, :boolean
    attribute :orig_gw_id_eq, :integer
    attribute :orig_gw_external_id_eq, :integer
    attribute :term_gw_id_eq, :integer
    attribute :term_gw_external_id_eq, :integer
    attribute :duration_eq, :integer
    attribute :duration_gteq, :integer
    attribute :duration_lteq, :integer
    attribute :customer_auth_external_type_eq, :string_presence
    attribute :customer_auth_external_type_not_eq, :string_presence
    attribute :customer_auth_external_id_in, :integer, array: { reject_blank: true }
    attribute :dst_country_iso_in, :string, array: { reject_blank: true }
    attribute :src_country_iso_in, :string, array: { reject_blank: true }

    def customer_auth_external_id_in=(v)
      super(v.presence)
    end

    def dst_country_iso_in=(v)
      super(v.presence)
    end

    def src_country_iso_in=(v)
      super(v.presence)
    end
  end

  STATUS_PENDING = 'Pending'
  STATUS_COMPLETED = 'Completed'
  STATUS_FAILED = 'Failed'
  STATUS_DELETED = 'Deleted'
  STATUSES = [
    STATUS_PENDING,
    STATUS_COMPLETED,
    STATUS_FAILED,
    STATUS_DELETED
  ].freeze

  REGULAR_FILTERS = %i[
    src_country_iso_in
    dst_country_iso_in
  ].freeze

  WITH_TIMEZONE_TIME_FORMAT = 'with_timezone'
  WITHOUT_TIMEZONE_TIME_FORMAT = 'without_timezone'
  ROUND_TO_SECONDS_TIME_FORMAT = 'round_to_seconds'

  ALLOWED_TIME_FORMATS = [
    WITH_TIMEZONE_TIME_FORMAT,
    WITHOUT_TIMEZONE_TIME_FORMAT,
    ROUND_TO_SECONDS_TIME_FORMAT
  ].freeze

  alias_attribute :export_type, :type

  # need for activeadmin form
  attr_accessor :customer_acc_id_eq, :is_last_cdr_eq, :time_start_gteq, :time_start_lteq, :time_start_lt

  json_attribute :filters, class_name: 'CdrExport::FiltersModel'

  belongs_to :customer_account, class_name: 'Account', optional: true

  validates :status, :fields, :filters, presence: true
  validate :validate_filters
  validate :validate_fields
  validate :validate_customer_account

  before_validation(on: :create) do
    self.status ||= STATUS_PENDING
    self.type ||= 'Base'
  end

  after_create :enqueue_export_job
  after_update :enqueue_remove_file_job, if: :saved_change_deleted?

  def fields=(f)
    self[:fields] = f.map(&:presence).compact
  end

  def export_sql
    scope = Cdr::Cdr.select(select_sql)
    scope = apply_joins_for!(scope)
    scope = apply_filters_for!(scope)
    scope.order(export_order).ransack(ransack_filters!).result.to_sql
  end

  def select_sql
    transformed_fields.join(', ')
  end

  def completed?
    status == STATUS_COMPLETED
  end

  def deleted?
    status == STATUS_DELETED
  end

  def self.allowed_filters
    FiltersModel.attribute_types.keys.map(&:to_s)
  end

  # any cdr columns
  def self.allowed_fields
    Cdr::Cdr.column_names + %w[
      src_country_name
      dst_country_name
      src_network_name
      dst_network_name
    ]
  end

  define_memoizable :filters_json, apply: -> { filters.as_json.symbolize_keys }

  private

  def validate_filters
    return if filters.blank?

    if filters._unknown_attributes.any?
      message = "#{filters._unknown_attributes.keys.join(', ')} not allowed"
      errors.add(:filters, message)
    end

    if filters.time_start_gteq.nil?
      errors.add(:filters, 'requires time_start_gteq')
    end

    if filters.time_start_lt.nil? && filters.time_start_lteq.nil?
      errors.add(:filters, 'requires time_start_lteq')
    end
  end

  def validate_fields
    extra_fields = fields - self.class.allowed_fields
    if extra_fields.any?
      errors.add(:fields, "#{extra_fields.join(', ')} not allowed")
    end
  end

  def validate_customer_account
    errors.add(:customer_account, :invalid) if customer_account_id && customer_account.nil?
    errors.add(:customer_account, 'requires customer account') if customer_account && !customer_account.contractor.customer
  end

  def enqueue_export_job
    # dj which exports CDRs into CSV
    Worker::CdrExportJob.perform_later(id)
  end

  def enqueue_remove_file_job
    Worker::RemoveCdrExportFileJob.perform_later(id)
  end

  def saved_change_deleted?
    saved_change_to_attribute?(:status) && deleted?
  end

  def transformed_fields
    fields.map do |f|
      case f
      when 'id'
        'cdr.cdr.id AS "ID"'
      when 'src_country_name'
        'src_c.name AS "Src Country Name"'
      when 'dst_country_name'
        'dst_c.name AS "Dst Country Name"'
      when 'src_network_name'
        'src_n.name AS "Src Network Name"'
      when 'dst_network_name'
        'dst_n.name AS "Dst Network Name"'
      when *Cdr::Cdr::TIME_SPECIFIC_FIELDS
        format_time_field(f)
      else
        "#{f} AS \"#{f.titleize}\""
      end
    end
  end

  def format_time_field(column)
    case time_format
    when WITH_TIMEZONE_TIME_FORMAT
      # With timezone: e.g. 2025-02-03 20:21:32.118457+00
      "cdr.cdr.#{column} AS \"#{column.titleize}\""
    when WITHOUT_TIMEZONE_TIME_FORMAT
      # Without timezone: e.g. 2025-02-03 20:21:32.118457
      "cdr.cdr.#{column}::timestamp AS \"#{column.titleize}\""
    when ROUND_TO_SECONDS_TIME_FORMAT
      # Round to seconds: e.g. 2025-02-03 20:21:32
      %(to_char(cdr.cdr.#{column}, 'YYYY-MM-DD HH24:MI:SS') AS "#{column.titleize}")
    else
      # Fallback to default (with timezone)
      "#{column} AS \"#{column.titleize}\""
    end
  end

  def apply_joins_for!(scope)
    if fields.include?('src_country_name') || filters_json.key?(:src_country_iso_in)
      scope = scope.joins("#{join_type_for(filters_json[:src_country_iso_in])} JOIN external_data.countries as src_c ON cdr.cdr.src_country_id = src_c.id")
    end

    if fields.include?('dst_country_name') || filters_json.key?(:dst_country_iso_in)
      scope = scope.joins("#{join_type_for(filters_json[:dst_country_iso_in])} JOIN external_data.countries as dst_c ON cdr.cdr.dst_country_id = dst_c.id")
    end

    if fields.include?('src_network_name')
      scope = scope.joins('LEFT JOIN external_data.networks as src_n ON cdr.cdr.src_network_id = src_n.id')
    end

    if fields.include?('dst_network_name')
      scope = scope.joins('LEFT JOIN external_data.networks as dst_n ON cdr.cdr.dst_network_id = dst_n.id')
    end

    scope
  end

  def join_type_for(filter)
    filter.present? ? 'INNER' : 'LEFT'
  end

  def apply_filters_for!(scope)
    scope = scope.where(src_c: { iso2: filters_json[:src_country_iso_in] }) if filters_json.key?(:src_country_iso_in)
    scope = scope.where(dst_c: { iso2: filters_json[:dst_country_iso_in] }) if filters_json.key?(:dst_country_iso_in)
    scope
  end

  def ransack_filters!
    filters = filters_json.except(*REGULAR_FILTERS)
    filters[:routing_tag_ids_empty] = filters[:routing_tag_ids_empty].to_s
    filters
  end

  def export_order
    'cdr.cdr.time_start DESC'
  end
end
