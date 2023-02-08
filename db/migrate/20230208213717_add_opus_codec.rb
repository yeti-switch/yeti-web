class AddOpusCodec < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      INSERT INTO class4.codecs (id, name) VALUES (21, 'opus/48000/2');
    }
  end

  def down
    execute %q{
      delete from class4.codecs where id=21;
    }
  end

end
