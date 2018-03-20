# == Schema Information
#
# Table name: cdr_exports
#
#  id           :integer          not null, primary key
#  status       :string           not null
#  fields       :string           default([]), is an Array
#  filters      :json             not null
#  callback_url :string
#  type         :string           not null
#  created_at   :datetime
#  updated_at   :datetime
#

class CdrExport < Yeti::ActiveRecord
  self.table_name = 'cdr_exports'
  self.store_full_sti_class = false

  STATUS_PENDING = 'Pending'.freeze
  STATUS_COMPLETED = 'Completed'.freeze
  STATUS_FAILED = 'Failed'.freeze
  ALLOWED_FILTERS = [
    'time_start_lteq',
    'time_start_gteq',
    'success_eq',
    'customer_auth_external_id_eq',
    'failed_resource_type_id_eq',
    'src_prefix_in_contains',
    'dst_prefix_in_contains',
    'src_prefix_routing_contains',
    'dst_prefix_routing_contains',
    'customer_acc_external_id_eq',
    'is_last_cdr_eq'
  ].freeze
  #any cdr columns
  ALLOWED_FIELDS = Cdr::Cdr.column_names.freeze

  validates_presence_of :status, :fields, :filters
  validate do
    if filters.keys.exclude?('time_start_lteq') || filters.keys.exclude?('time_start_gteq')
      errors.add(:filters, 'requires time_start_lteq & time_start_gteq')
    end
  end
  validate do
    extra_fields = fields - ALLOWED_FIELDS
    if extra_fields.any?
      errors.add(:fields, "#{extra_fields.join(', ')} not allowed")
    end
    extra_filters = filters.keys - ALLOWED_FILTERS
    if extra_filters.any?
      errors.add(:filters, "#{extra_filters.join(', ')} not allowed")
    end
  end

  before_validation(on: :create) do
    self.status ||= STATUS_PENDING
    self.type ||= 'Base'
  end

  after_create do
    #dj which exports CDRs into CSV
    Worker::CdrExportJob.perform_later(self.id)
  end

  alias_attribute :export_type, :type

  def export_sql
    Cdr::Cdr.select(fields.join(', ')).order('time_start desc').ransack(filters).result.to_sql
  end
end
