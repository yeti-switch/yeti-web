class DtmfInbandRx < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      insert into class4.dtmf_receive_modes(id,name) values(4,'Inband');
      insert into class4.dtmf_receive_modes(id,name) values(5,'Inband OR RFC 2833');
    }
  end

  def down
    execute %q{
      delete from class4.dtmf_receive_modes where id in (4,5);
    }
  end
end
