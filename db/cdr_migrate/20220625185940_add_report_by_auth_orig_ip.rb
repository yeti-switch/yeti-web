class AddReportByAuthOrigIp < ActiveRecord::Migration[6.1]
  def up
    execute %q{
    alter table reports.cdr_custom_report_data add auth_orig_ip varchar;
    alter table reports.cdr_interval_report_data add auth_orig_ip varchar;
            }
  end

  def down
    execute %q{
    alter table reports.cdr_custom_report_data drop column auth_orig_ip;
    alter table reports.cdr_interval_report_data drop column auth_orig_ip;
            }
  end
end
