class SloveniaPrefixesFix < ActiveRecord::Migration[7.0]
  def up
    execute %q{
        INSERT INTO sys.network_types (id, name, uuid) VALUES ( 2, 'Landline', '706ab0ee-f258-11ed-b425-00ffaa112233');
        INSERT INTO sys.network_types (id, name, uuid) VALUES ( 3, 'Mobile', '706ab648-f258-11ed-b425-00ffaa112233');
        INSERT INTO sys.network_types (id, name, uuid) VALUES ( 4, 'National', '706ab80a-f258-11ed-b425-00ffaa112233');
        INSERT INTO sys.network_types (id, name, uuid) VALUES ( 5, 'Shared Cost', '706ab9b8-f258-11ed-b425-00ffaa112233');
        INSERT INTO sys.network_types (id, name, uuid) VALUES ( 6, 'Toll-Free', '706abb48-f258-11ed-b425-00ffaa112233');
        INSERT INTO sys.network_types (id, name, uuid) VALUES ( 7, 'Special Services', '706abcce-f258-11ed-b425-00ffaa112233');
    }
  end

  def down
    execute %q{
        delete from sys.network_types WHERE id in (2,3,4,5,6,7);
    }
  end
end
