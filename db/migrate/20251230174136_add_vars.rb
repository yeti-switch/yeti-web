class AddVars < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table class4.customers_auth add variables jsonb;
      alter table class4.customers_auth_normalized add variables jsonb;
      alter table class4.numberlists add variables jsonb;
      alter table class4.numberlist_items add variables jsonb;
    }
  end

  def down
    execute %q{
      alter table class4.customers_auth drop column variables;
      alter table class4.customers_auth_normalized drop column variables;
      alter table class4.numberlists drop column variables;
      alter table class4.numberlist_items drop column variables;
    }
  end

end
