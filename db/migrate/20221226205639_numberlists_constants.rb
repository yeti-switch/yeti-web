class NumberlistsConstants < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table class4.numberlist_items drop constraint numberlist_items_action_id_fkey;
      alter table class4.numberlists drop constraint numberlists_default_action_id_fkey;
      alter table class4.numberlists drop constraint blacklists_mode_id_fkey;
      drop table class4.numberlist_actions;
      drop table class4.numberlist_modes;
    }

  end
  def down
    execute %q{
      create table class4.numberlist_actions(
        id smallint primary key,
        name varchar not null unique
      );
      INSERT INTO numberlist_actions (id, name) VALUES (1, 'Reject call');
      INSERT INTO numberlist_actions (id, name) VALUES (2, 'Allow call');

      create table class4.numberlist_modes(
        id smallint primary key,
        name varchar not null unique
      );

      INSERT INTO class4.numberlist_modes (id, name) VALUES (1, 'Strict number match');
      INSERT INTO class4.numberlist_modes (id, name) VALUES (2, 'Prefix match');
      INSERT INTO class4.numberlist_modes (id, name) VALUES (3, 'Random');

      ALTER TABLE ONLY class4.numberlist_items
        ADD CONSTRAINT numberlist_items_action_id_fkey FOREIGN KEY (action_id) REFERENCES class4.numberlist_actions(id);

      ALTER TABLE ONLY class4.numberlists
        ADD CONSTRAINT numberlists_default_action_id_fkey FOREIGN KEY (default_action_id) REFERENCES class4.numberlist_actions(id);

      ALTER TABLE ONLY class4.numberlists
        ADD CONSTRAINT blacklists_mode_id_fkey FOREIGN KEY (mode_id) REFERENCES class4.numberlist_modes(id);
      }
  end
end
