class AddRoutesetDiscriminator < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      create table class4.routeset_discriminators(
        id smallserial primary key,
        name varchar unique not null
      );
      insert into class4.routeset_discriminators(name) values('default');

      alter table class4.dialpeers add routeset_discriminator_id smallint not null default 1 references class4.routeset_discriminators(id);

      alter table data_import.import_dialpeers
        add routeset_discriminator_id smallint,
        add routeset_discriminator_name varchar;
    }
  end

  def down
    execute %q{
      alter table data_import.import_dialpeers
        drop routeset_discriminator_id,
        drop routeset_discriminator_name;

      alter table class4.dialpeers drop column routeset_discriminator_id;
      drop table class4.routeset_discriminators;
    }
  end
end
