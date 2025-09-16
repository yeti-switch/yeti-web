class GwGroupLimitRerouting < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table class4.gateway_groups add max_rerouting_attempts smallint not null default 10;
      alter table data_import.import_gateway_groups add max_rerouting_attempts smallint;
    }
  end

  def down
    execute %q{
      alter table class4.gateway_groups drop column max_rerouting_attempts;
      alter table data_import.import_gateway_groups drop column max_rerouting_attempts;
    }
  end
end
