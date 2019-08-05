class NewNatHandlingMode < ActiveRecord::Migration[5.2]
#TODO:
#  remove tag from lnp_cache
#  remove transparent_dialor_id from gateways
#  remove dialog_nat_handling from gateways
#    column :transparent_seqno
#    column :transparent_ssrc
#
  def up
    execute %q{
      create table class4.gateway_nat_handling_modes (
        id smallint primary key,
        name varchar not null unique
      );
      insert into class4.gateway_nat_handling_modes( id,name) values (0, 'Disabled');
      insert into class4.gateway_nat_handling_modes( id,name) values (1, 'Learn next hop from incoming requests');
      insert into class4.gateway_nat_handling_modes( id,name) values (2, 'Use R-Uri as next hop(Ignore incoming contact)');


      alter table class4.gateways
        add nat_handling_mode_id smallint not null default 1 references class4.gateway_nat_handling_modes(id);

      alter table class4.lnp_cache
        add routing_tag_id smallint;
    }
  end


  def down
    execute %q{
--      drop schema switch19 cascade;
      alter table class4.gateways drop column nat_handling_mode_id;
      drop table class4.gateway_nat_handling_modes;

      alter table class4.lnp_cache drop column routing_tag_id;
    }
  end
end
