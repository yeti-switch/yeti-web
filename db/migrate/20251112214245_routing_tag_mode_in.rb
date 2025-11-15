class RoutingTagModeIn < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter extension yeti update;
      alter table class4.dialpeers drop constraint dialpeers_routing_tag_mode_id_fkey;
      alter table class4.destinations drop constraint destinations_routing_tag_mode_id_fkey;
      alter table class4.routing_tag_detection_rules drop constraint routing_tag_detection_rules_routing_tag_mode_id_fkey;
      alter table ratemanagement.pricelist_items drop constraint fk_rails_161e735c3a;
      alter table ratemanagement.projects drop constraint fk_rails_8c0fbee7b0;

      drop table class4.routing_tag_modes;
    }
  end

  def down
    execute %q{
      create table class4.routing_tag_modes(
        id smallint primary key,
        name varchar not null unique
      );
      insert into class4.routing_tag_modes(id,name) values( 0, 'OR');
      insert into class4.routing_tag_modes(id,name) values( 1, 'AND');

      alter table class4.dialpeers add constraint dialpeers_routing_tag_mode_id_fkey foreign key (routing_tag_mode_id) references routing_tag_modes(id);
      alter table class4.destinations add constraint destinations_routing_tag_mode_id_fkey  foreign key (routing_tag_mode_id) references routing_tag_modes(id);
      alter table class4.routing_tag_detection_rules add constraint routing_tag_detection_rules_routing_tag_mode_id_fkey foreign key (routing_tag_mode_id) references routing_tag_modes(id);
      alter table ratemanagement.pricelist_items add constraint fk_rails_161e735c3a foreign key (routing_tag_mode_id) references routing_tag_modes(id);
      alter table ratemanagement.projects add constraint fk_rails_8c0fbee7b0 foreign key (routing_tag_mode_id) references routing_tag_modes(id);

    }
  end
end
