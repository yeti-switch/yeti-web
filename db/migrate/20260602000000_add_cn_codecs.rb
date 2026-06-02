# frozen_string_literal: true

class AddCnCodecs < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      insert into class4.codecs(id,name) values (24,'CN/8000');
      insert into class4.codecs(id,name) values (25,'CN/16000');
      insert into class4.codecs(id,name) values (26,'CN/24000');
      insert into class4.codecs(id,name) values (27,'CN/32000');
      insert into class4.codecs(id,name) values (28,'CN/48000');
    }
  end

  def down
    execute %q{
      delete from class4.codecs where id in (24,25,26,27,28);
    }
  end
end
