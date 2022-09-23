class AddCanceForceRouteset < ActiveRecord::Migration[6.1]
  def down
    execute %q{
      alter table class4.gateways drop column force_cancel_routeset;
    }
  end

  def up
    execute %q{
      alter table class4.gateways add force_cancel_routeset boolean not null default false;
    }
  end
end
