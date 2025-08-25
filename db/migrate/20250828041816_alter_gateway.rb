class AlterGateway < ActiveRecord::Migration[7.2]
  def up
    execute 'alter table class4.gateways add uuid uuid not null default uuid_generate_v4();'
  end

  def down
    execute 'alter table class4.gateways drop column uuid;'
  end
end
