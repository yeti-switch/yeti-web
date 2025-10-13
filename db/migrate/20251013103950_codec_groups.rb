class CodecGroups < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      insert into class4.codecs(id,name) values (22,'AMR/8000');
      insert into class4.codecs(id,name) values (23,'AMR-WB/16000');
    }
  end

  def down
    execute %q{
      delete from class4.codecs where id in (22,23);
    }
  end
end
