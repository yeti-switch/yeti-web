class MigrateToConstants < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table class4.routing_plans drop constraint routing_plans_sorting_id_fkey;
      drop table class4.sortings;

      alter table class4.rateplans drop constraint rateplans_profit_control_mode_id_fkey;
      alter table class4.destinations drop constraint destinations_profit_control_mode_id_fkey;
      drop table class4.rate_profit_control_modes;

      alter table class4.destinations drop constraint destinations_rate_policy_id_fkey;
      drop table class4.destination_rate_policy;

      drop table class4.disconnect_initiators;
    }
  end

  def down
        execute %q{
          create table class4.disconnect_initiators (
            id integer primary key,
            name varchar
          );

          INSERT INTO disconnect_initiators (id, name) VALUES (0, 'Traffic manager');
          INSERT INTO disconnect_initiators (id, name) VALUES (1, 'Traffic switch');
          INSERT INTO disconnect_initiators (id, name) VALUES (2, 'Destination');
          INSERT INTO disconnect_initiators (id, name) VALUES (3, 'Origination');

          CREATE TABLE class4.destination_rate_policy (
            id integer primary key,
            name character varying unique NOT NULL
          );
          INSERT INTO class4.destination_rate_policy (id, name) VALUES (1, 'Fixed');
          INSERT INTO class4.destination_rate_policy (id, name) VALUES (2, 'Based on used dialpeer');
          INSERT INTO class4.destination_rate_policy (id, name) VALUES (3, 'MIN(Fixed,Based on used dialpeer)');
          INSERT INTO class4.destination_rate_policy (id, name) VALUES (4, 'MAX(Fixed,Based on used dialpeer)');
          ALTER TABLE ONLY class4.destinations
            ADD CONSTRAINT destinations_rate_policy_id_fkey FOREIGN KEY (rate_policy_id) REFERENCES class4.destination_rate_policy(id);

          CREATE TABLE class4.rate_profit_control_modes (
            id smallint primary key,
            name character varying unique NOT NULL
          );
          INSERT INTO class4.rate_profit_control_modes (id, name) VALUES (1, 'no control');
          INSERT INTO class4.rate_profit_control_modes (id, name) VALUES (2, 'per call');
          ALTER TABLE ONLY class4.rateplans
            ADD CONSTRAINT rateplans_profit_control_mode_id_fkey FOREIGN KEY (profit_control_mode_id) REFERENCES class4.rate_profit_control_modes(id);
          ALTER TABLE ONLY class4.destinations
            ADD CONSTRAINT destinations_profit_control_mode_id_fkey FOREIGN KEY (profit_control_mode_id) REFERENCES class4.rate_profit_control_modes(id);

          CREATE TABLE class4.sortings (
            id serial primary key,
            name character varying,
            description character varying,
            use_static_routes boolean DEFAULT false NOT NULL
          );
          INSERT INTO class4.sortings (id, name, description, use_static_routes) VALUES (2, 'LCR, No ACD&ASR control', 'Without ACD&ASR control', false);
          INSERT INTO class4.sortings (id, name, description, use_static_routes) VALUES (3, 'Prio,LCR, ACD&ASR control', 'Same as default, but priotity has more weight', false);
          INSERT INTO class4.sortings (id, name, description, use_static_routes) VALUES (1, 'LCR,Prio, ACD&ASR control', 'Default dialpeer sorting method', false);
          INSERT INTO class4.sortings (id, name, description, use_static_routes) VALUES (4, 'LCRD, Prio, ACD&ASR control', 'Same as default, but take in account diff between costs', false);
          INSERT INTO class4.sortings (id, name, description, use_static_routes) VALUES (5, 'Route testing', NULL, false);
          INSERT INTO class4.sortings (id, name, description, use_static_routes) VALUES (6, 'QD-Static, LCR, ACD&ASR control', NULL, true);
          INSERT INTO class4.sortings (id, name, description, use_static_routes) VALUES (7, 'Static only, No ACD&ASR control', NULL, true);
          ALTER TABLE ONLY class4.routing_plans
            ADD CONSTRAINT routing_plans_sorting_id_fkey FOREIGN KEY (sorting_id) REFERENCES class4.sortings(id);
        }
  end
end
