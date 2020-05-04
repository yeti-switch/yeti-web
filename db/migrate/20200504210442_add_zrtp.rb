class AddZrtp < ActiveRecord::Migration[5.2]
  def up
    execute %q{
      insert into class4.gateway_media_encryption_modes(id,name) values (3,'SRTP ZRTP');
    }
  end

  def down
    execute %q{
      delete from class4.gateway_media_encryption_modes where id=3;
    }
  end
end
