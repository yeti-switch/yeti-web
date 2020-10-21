class ManualIdDefiningPopsNodes < ActiveRecord::Migration[5.2]
  def up
    execute %q{
    DROP SEQUENCE if exists sys.pop_id_seq cascade;
    DROP SEQUENCE if exists sys.node_id_seq cascade;
    alter table sys.nodes
      drop column signalling_ip,
      drop column signalling_port;
    }
  end

  def down
    execute %q{
    alter table sys.nodes
      add signalling_ip varchar,
      add signalling_port integer;
    create sequence sys.pop_id_seq;
    create sequence sys.node_id_seq;
    alter table sys.pops alter column id set default nextval('sys.pop_id_seq'::regclass);
    alter table sys.nodes alter column id set default nextval('sys.node_id_seq'::regclass);
}
  end
end
