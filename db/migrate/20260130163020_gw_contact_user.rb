class GwContactUser < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table class4.gateways add contact_user varchar;
      alter table data_import.import_gateways add contact_user varchar;
    }
  end

  def down
    execute %q{
      alter table class4.gateways drop column contact_user;
      alter table data_import.import_gateways drop column contact_user;
    }
  end

end
