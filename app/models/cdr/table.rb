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
  extend PgCdrPartitioning

  self.table_name = 'sys.cdr_tables'

  has_paper_trail class_name: 'AuditLogItem'

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

  def _reload_trigger
    self.reload_cdr_i_tgf
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

  def self.add_partition
    today = Date.today
    transaction do
      create_partition(today.prev_month)
      create_partition(today)
      create_partition(today.next_month)
    end
  end

  def self.partitions
    res = connection.execute %q{
      SELECT tablename
      FROM pg_tables
      WHERE schemaname = 'cdr' AND tablename SIMILAR TO 'cdr_\d{6}'
    }
    res.values.flatten
  end

  def remove
    self.destroy!
  end

end
