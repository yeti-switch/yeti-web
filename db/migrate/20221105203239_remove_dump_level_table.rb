class RemoveDumpLevelTable < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table class4.customers_auth drop constraint customers_auth_dump_level_id_fkey;
      drop table class4.dump_level;

      alter type switch20.callprofile_ty alter attribute dump_level_id type smallint;
      alter table class4.customers_auth alter column dump_level_id type smallint;
      alter table class4.customers_auth_normalized alter column dump_level_id type smallint;

    }
  end
  def down
    execute %q{
  CREATE TABLE class4.dump_level (
    id integer primary key,
    name character varying unique NOT NULL,
    log_sip boolean DEFAULT false NOT NULL,
    log_rtp boolean DEFAULT false NOT NULL
  );


INSERT INTO class4.dump_level (id, name, log_sip, log_rtp) VALUES (3, 'Capture all traffic', true, true);
INSERT INTO class4.dump_level (id, name, log_sip, log_rtp) VALUES (0, 'Capture nothing', false, false);
INSERT INTO class4.dump_level (id, name, log_sip, log_rtp) VALUES (2, 'Capture rtp traffic', true, false);
INSERT INTO class4.dump_level (id, name, log_sip, log_rtp) VALUES (1, 'Capture signaling traffic', true, false);

alter type switch20.callprofile_ty alter attribute dump_level_id type integer;
alter table class4.customers_auth alter column dump_level_id type integer;
alter table class4.customers_auth_normalized alter column dump_level_id type integer;

alter table class4.customers_auth add constraint customers_auth_dump_level_id_fkey FOREIGN KEY (dump_level_id) REFERENCES class4.dump_level(id);



            }

  end
end
