# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr_exports
#
#  id           :integer(4)       not null, primary key
#  callback_url :string
#  fields       :string           default([]), not null, is an Array
#  filters      :json             not null
#  rows_count   :integer(4)
#  status       :string           not null
#  type         :string           not null
#  created_at   :datetime
#  updated_at   :datetime
#

class CdrExport < Yeti::ActiveRecord
  self.table_name = 'cdr_exports'
  self.store_full_sti_class = false

  class FiltersModel < JsonAttributeModel
    attribute :time_start_gteq, :db_datetime
    attribute :time_start_lteq, :db_datetime
    attribute :customer_acc_id_eq, :integer
    attribute :is_last_cdr_eq, :boolean
    attribute :success_eq, :boolean
    attribute :customer_auth_external_id_eq, :integer
    attribute :failed_resource_type_id_eq, :integer
    attribute :src_prefix_in_contains, :string
    attribute :dst_prefix_in_contains, :string
    attribute :src_prefix_routing_contains, :string
    attribute :dst_prefix_routing_contains, :string
    attribute :customer_acc_external_id_eq, :integer

    private

    def write_attribute(attr_name, value)
      super
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

  # need for activeadmin form
  attr_accessor :customer_acc_id_eq,
                :is_last_cdr_eq, :time_start_gteq, :time_start_lteq

  json_attribute :filters, class_name: 'CdrExport::FiltersModel'

  validates :status, :fields, :filters, presence: true
  validate do
    if filters.time_start_gteq.nil? || filters.time_start_lteq.nil?
      errors.add(:filters, 'requires time_start_lteq & time_start_gteq')
    end
  end
  validate do
    extra_fields = fields - self.class.allowed_fields
    if extra_fields.any?
      errors.add(:fields, "#{extra_fields.join(', ')} not allowed")
    end
  end

  def fields=(f)
    self[:fields] = f.map(&:presence).compact
  end

  before_validation(on: :create) do
    self.status ||= STATUS_PENDING
    self.type ||= 'Base'
  end

  after_create do
    # dj which exports CDRs into CSV
    Worker::CdrExportJob.perform_later(id)
  end

  after_update if: proc { saved_change_to_attribute?(:status) && deleted? } do
    Worker::RemoveCdrExportFileJob.perform_later(id)
  end

  alias_attribute :export_type, :type

  def export_sql
    s = Cdr::Cdr.select(select_sql)
    s = s.order('time_start desc')
    s = s.ransack(filters.as_json).result
    if fields.include?('src_country_name')
      s = s.joins('LEFT JOIN external_data.countries as src_c ON cdr.cdr.src_country_id = src_c.id')
    end
    if fields.include?('dst_country_name')
      s = s.joins('LEFT JOIN external_data.countries as dst_c ON cdr.cdr.dst_country_id = dst_c.id')
    end
    if fields.include?('src_network_name')
      s = s.joins('LEFT JOIN external_data.networks as src_n ON cdr.cdr.src_network_id = src_n.id')
    end
    if fields.include?('dst_network_name')
      s = s.joins('LEFT JOIN external_data.networks as dst_n ON cdr.cdr.dst_network_id = dst_n.id')
    end
    s.to_sql
  end

  def select_sql
    transformed_fields.join(', ')
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
      else
        "#{f} AS \"#{f.titleize}\""
      end
    end
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
end
