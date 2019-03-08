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

      create table class4.gateway_group_balancing_modes(
        id smallint primary key,
        name varchar not null unique
      );

      insert into class4.gateway_group_balancing_modes(id,name) values(1,'Priority/Weigth balancing');
      insert into class4.gateway_group_balancing_modes(id,name) values(2,'Priority/Weigth balancing. Prefer gateways from same POP');
      insert into class4.gateway_group_balancing_modes(id,name) values(3,'Priority/Weigth balancing. Exclude gateways from other POPs');

      alter table class4.gateway_groups
        add balancing_mode_id smallint not null default 1 references class4.gateway_group_balancing_modes(id);

      update class4.gateway_groups set balancing_mode_id=2 where prefer_same_pop;

      alter table data_import.import_gateway_groups drop column prefer_same_pop;
      alter table data_import.import_gateway_groups
        add balancing_mode_id smallint,
        add balancing_mode_name varchar;
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

      update class4.gateway_groups set prefer_same_pop=true where balancing_mode_id!=1;

      alter table class4.gateway_groups drop column balancing_mode_id;
      drop table class4.gateway_group_balancing_modes;


      alter table data_import.import_gateway_groups add prefer_same_pop boolean;
      alter table data_import.import_gateway_groups
        drop column balancing_mode_id,
        drop column balancing_mode_name;

    }
  end
end
