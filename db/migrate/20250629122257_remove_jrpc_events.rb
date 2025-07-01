class RemoveJrpcEvents < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      drop table sys.events;
      drop sequence if exists sys.events_id_seq;

      delete from sys.jobs where name='EventProcessor';
    }
  end

  def down
    execute %q{
      create table sys.events(
        id serial primary key,
        command varchar not null,
        retries integer not null default 0,
        node_id integer not null references sys.nodes(id),
        created_at timestamp with time zone not null default now(),
        updated_at timestamp with time zone,
        last_error varchar
      );

      insert into sys.jobs(id,name) values (2,'EventProcessor');
    }
  end


end
