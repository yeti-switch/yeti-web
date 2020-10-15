class ManualIdDefiningPopsNodes < ActiveRecord::Migration[5.2]
  def up
    execute %q{
    DROP SEQUENCE if exists sys.pop_id_seq cascade;
    DROP SEQUENCE if exists sys.node_id_seq cascade;
    }
  end

  def down
    execute %q{
    create sequence sys.pop_id_seq;
    create sequence sys.node_id_seq;
    alter table sys.pops alter column id set default nextval('sys.pop_id_seq'::regclass);
    alter table sys.nodes alter column id set default nextval('sys.node_id_seq'::regclass);
}
  end
end
