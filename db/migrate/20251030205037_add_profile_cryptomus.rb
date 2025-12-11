class AddProfileCryptomus < ActiveRecord::Migration[7.2]
def up
    execute %q{
      alter table sys.customer_portal_access_profiles add payments_cryptomus boolean not null default false;
    }
  end

  def down
    execute %q{
      alter table sys.customer_portal_access_profiles drop column payments_cryptomus;
    }
  end
end
