class AddPaiSendMode < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table class4.gateways add pai_send_mode_id smallint not null default 0;
    }
  end

  def down
    execute %q{
      alter table class4.gateways drop column pai_send_mode_id;
    }
  end
end
