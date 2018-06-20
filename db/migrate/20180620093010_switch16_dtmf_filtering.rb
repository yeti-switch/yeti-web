class Switch16DtmfFiltering < ActiveRecord::Migration[5.1]
  def up
    execute %q{

      create table class4.gateway_inbound_dtmf_filtering_modes(
        id smallint primary key,
        name varchar not null unique
      );

      insert into class4.gateway_inbound_dtmf_filtering_modes(id,name) values('1','Inherit configuration from other call leg');
      insert into class4.gateway_inbound_dtmf_filtering_modes(id,name) values('2','Disable');
      insert into class4.gateway_inbound_dtmf_filtering_modes(id,name) values('3','Remove DTMF');

      alter table class4.gateways
        add rx_inbound_dtmf_filtering_mode_id smallint not null references class4.gateway_inbound_dtmf_filtering_modes(id) default(1),
        add tx_inbound_dtmf_filtering_mode_id smallint not null references class4.gateway_inbound_dtmf_filtering_modes(id) default(1),
        add weight smallint not null default 100;

      alter table data_import.import_gateways
        add rx_inbound_dtmf_filtering_mode_id smallint,
        add rx_inbound_dtmf_filtering_mode_name varchar,
        add tx_inbound_dtmf_filtering_mode_id smallint,
        add tx_inbound_dtmf_filtering_mode_name varchar,
        add weight smallint;

    }
  end

  def down

    execute %q{

      alter table data_import.import_gateways
          drop column rx_inbound_dtmf_filtering_mode_id,
          drop column rx_inbound_dtmf_filtering_mode_name,
          drop column tx_inbound_dtmf_filtering_mode_id,
          drop column tx_inbound_dtmf_filtering_mode_name,
          drop column weight;

      alter table class4.gateways
          drop column rx_inbound_dtmf_filtering_mode_id,
          drop column tx_inbound_dtmf_filtering_mode_id,
          drop column weight;

        drop table  class4.gateway_inbound_dtmf_filtering_modes;
    }

  end
end
