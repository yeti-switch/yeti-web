class CustomersAuthIpNotNull < ActiveRecord::Migration
  def up
    execute %q{
      UPDATE class4.customers_auth SET ip='{127.0.0.0/8}' WHERE ip='{}';
      UPDATE class4.customers_auth_normalized SET ip='127.0.0.0/8' WHERE ip IS NULL;
      
      ALTER TABLE class4.customers_auth ALTER ip SET DEFAULT '{127.0.0.0/8}';
      ALTER TABLE class4.customers_auth ADD CONSTRAINT ip_not_empty CHECK (ip != '{}');
      ALTER TABLE class4.customers_auth_normalized ALTER ip SET NOT NULL;
    }
  end

  def down
    execute %q{
      ALTER TABLE class4.customers_auth ALTER COLUMN ip SET DEFAULT '{}';
      ALTER TABLE class4.customers_auth DROP CONSTRAINT ip_not_empty;
      ALTER TABLE class4.customers_auth_normalized ALTER ip DROP NOT NULL;
    }
  end
end
