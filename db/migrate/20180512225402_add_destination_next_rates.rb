class AddDestinationNextRates < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      create table class4.destination_next_rates (
        id bigserial primary key,
        destination_id bigint not null references class4.destinations(id),
        initial_rate  numeric not null,
        next_rate numeric not null,
        initial_interval smallint not null,
        next_interval smallint not null,
        connect_fee numeric not null,
        apply_time timestamptz,
        created_at timestamptz,
        updated_at timestamptz,
        applied boolean not null default false,
        external_id bigint
      );
    }
  end
  def down
    execute %q{
      drop table class4.destination_next_rates;
    }
  end
end
