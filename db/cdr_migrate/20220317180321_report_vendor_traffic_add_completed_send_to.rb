class ReportVendorTrafficAddCompletedSendTo < ActiveRecord::Migration[6.1]
  def up
    execute %Q{
      ALTER TABLE reports.vendor_traffic_report
      ADD COLUMN completed boolean NOT NULL DEFAULT false
    }

    execute %Q{
      ALTER TABLE reports.vendor_traffic_report
      ADD COLUMN send_to integer[]
    }

    execute %Q{
      UPDATE reports.vendor_traffic_report
      SET completed = true
    }
  end

  def down
    execute %Q{
      ALTER TABLE reports.vendor_traffic_report
      DROP COLUMN completed
    }

    execute %Q{
      ALTER TABLE reports.vendor_traffic_report
      DROP COLUMN send_to
    }
  end
end
