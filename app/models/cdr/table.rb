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
  self.partition_schema = 'cdr'.freeze
  self.partition_key = :time_start
  self.trigger_function_name = 'cdr.cdr_i_tgf'.freeze
  self.trigger_name = 'cdr.cdr_i_tg'.freeze


  has_paper_trail class_name: 'AuditLogItem', on: [:destroy, :touch, :update]

  scope :active, -> { where(active: true) }

  def display_name
    "#{self.name}"
  end

  def destroy
    transaction do
      if self.active
        raise "Table used"
      end
      self.execute_sp("DROP TABLE #{self.name}")
      super
      _reload_trigger
    end
  end

  def unload
    self.execute_sp("SELECT sys.cdr_export_data(?,?)" , self.name, GuiConfig.cdr_unload_dir)
  end

  def archive
    transaction do
      self.active=false
      self.save
      self.execute_sp("ALTER TABLE #{self.name} NO INHERIT cdr.cdr")
      self.execute_sp("ALTER TABLE #{self.name} INHERIT cdr.cdr_archive")
      _reload_trigger
    end
  end

  def remove
    self.destroy!
  end

  def _reload_trigger
    self.class.reload_insertion_trigger
  end

end
