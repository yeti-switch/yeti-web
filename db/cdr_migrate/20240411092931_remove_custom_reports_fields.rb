class RemoveCustomReportsFields < ActiveRecord::Migration[7.0]

  def up
    execute %q{
      alter table reports.cdr_custom_report_data
        drop column orig_call_id,
        drop column term_call_id,
        drop column local_tag,
        drop column log_sip,
        drop column log_rtp,
        drop column dump_file,
        drop column profit,
        drop column customer_price,
        drop column vendor_price;
    }
  end

  def down
    execute %q{
      alter table reports.cdr_custom_report_data
        add orig_call_id varchar,
        add term_call_id varchar,
        add local_tag varchar,
        add log_sip boolean,
        add log_rtp boolean,
        add dump_file varchar,
        add profit numeric,
        add customer_price numeric,
        add vendor_price numeric;
    }
  end


end
