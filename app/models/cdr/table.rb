# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.cdr_tables
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  readable   :boolean          default(TRUE), not null
#  writable   :boolean          default(FALSE), not null
#  date_start :string           not null
#  date_stop  :string           not null
#  active     :boolean          default(TRUE), not null
#

class Cdr::Table < Cdr::Base
  self.table_name = 'sys.cdr_tables'

  include PgPartitioningMixin

  self.partitioned_model = Cdr::Cdr
  self.partition_schema = 'cdr'
  self.partition_key = :time_start
  self.trigger_function_name = 'cdr.cdr_i_tgf'
  self.trigger_name = 'cdr.cdr_i_tg'

  has_paper_trail class_name: 'AuditLogItem', on: %i[destroy touch update]

  scope :active, -> { where(active: true) }

  def display_name
    name.to_s
  end

  def destroy
    transaction do
      raise 'Table used' if active

      execute_sp("DROP TABLE #{name}")
      super
      _reload_trigger
    end
  end

  def unload
    execute_sp('SELECT sys.cdr_export_data(?,?)', name, GuiConfig.cdr_unload_dir)
  end

  def archive
    transaction do
      self.active = false
      save
      execute_sp("ALTER TABLE #{name} NO INHERIT cdr.cdr")
      execute_sp("ALTER TABLE #{name} INHERIT cdr.cdr_archive")
      _reload_trigger
    end
  end

  def remove
    destroy!
  end

  def _reload_trigger
    self.class.reload_insertion_trigger
  end
end
