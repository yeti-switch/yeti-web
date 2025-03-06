class CreateDestinationNextRatesIndexByDestinationId < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      CREATE INDEX IF NOT EXISTS "destination_next_rates_destination_id_idx" ON class4.destination_next_rates USING btree (destination_id);
    }
  end

  def down
    execute %q{
      DROP INDEX IF EXISTS "destination_next_rates_destination_id_idx";
    }
  end
end
