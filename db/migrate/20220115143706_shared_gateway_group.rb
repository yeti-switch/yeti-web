class SharedGatewayGroup < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table class4.gateway_groups add is_shared boolean not null default false;
            }
  end

  def down
    execute %q{
      alter table class4.gateway_groups drop column is_shared;
            }
  end
end
