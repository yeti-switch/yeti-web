class ReportsAddAreas < ActiveRecord::Migration[5.2]
  def up
    execute %q{
      alter table reports.cdr_custom_report_data
        add src_area_id integer,
        add dst_area_id integer,
        add src_network_id integer,
        add src_country_id integer,
        add lega_user_agent varchar,
        add legb_user_agent varchar,
        add p_charge_info_in varchar
    }
  end

  def down
    execute %q{
      alter table reports.cdr_custom_report_data
        drop column src_area_id,
        drop column dst_area_id,
        drop column src_network_id,
        drop column src_country_id,
        drop column lega_user_agent,
        drop column legb_user_agent,
        drop column p_charge_info_in;
    }
  end

end
