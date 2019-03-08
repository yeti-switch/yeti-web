class AddNumberlistToGateway < ActiveRecord::Migration[5.2]
  def up
    execute %q{
      alter table class4.gateways
        add preserve_anonymous_from_domain boolean not null default false,
        add termination_src_numberlist_id smallint,
        add termination_dst_numberlist_id smallint;

      alter table data_import.import_gateways
        add preserve_anonymous_from_domain boolean,
        add termination_src_numberlist_id smallint,
        add termination_src_numberlist_name varchar,
        add termination_dst_numberlist_id smallint,
        add termination_dst_numberlist_name varchar;


    }
  end

  def down
    execute %q{
      alter table class4.gateways
        drop column preserve_anonymous_from_domain,
        drop column termination_src_numberlist_id,
        drop column termination_dst_numberlist_id;

      alter table data_import.import_gateways
        drop column preserve_anonymous_from_domain,
        drop column termination_src_numberlist_id,
        drop column termination_src_numberlist_name,
        drop column termination_dst_numberlist_id,
        drop column termination_dst_numberlist_name;
    }
  end
end
