# frozen_string_literal: true

class AddAttemptFee < ActiveRecord::Migration[7.2]
  # attempt_fee mirrors connect_fee on every rate/config table, plus the two
  # composite types that carry the per-call fee snapshots through routing
  # (switch22.callprofile_ty) and batch settlement (billing.cdr_v2).
  def up
    execute %q{
      -- customer-side (destinations) and vendor-side (dialpeers) rate config.
      -- These are large tables, so add the column as plain NULLable here: this is an
      -- instant, metadata-only change with no row rewrite or long lock. The companion
      -- migration BackfillAttemptFeeNotNull backfills 0 and sets DEFAULT 0.0 + NOT NULL.
      ALTER TABLE class4.destinations ADD COLUMN attempt_fee numeric;
      ALTER TABLE class4.dialpeers ADD COLUMN attempt_fee numeric;

      -- scheduled rate changes. connect_fee is NOT NULL with no default, but attempt_fee
      -- is a newly-introduced optional fee, so keep DEFAULT 0.0 — any insert path that does
      -- not yet provide it gets "no fee" instead of a NOT NULL violation.
      ALTER TABLE class4.destination_next_rates ADD COLUMN attempt_fee numeric NOT NULL DEFAULT 0.0;
      ALTER TABLE class4.dialpeer_next_rates ADD COLUMN attempt_fee numeric NOT NULL DEFAULT 0.0;

      -- CSV import staging
      ALTER TABLE data_import.import_destinations ADD COLUMN attempt_fee numeric;
      ALTER TABLE data_import.import_dialpeers ADD COLUMN attempt_fee numeric;

      -- rate management pricelists
      ALTER TABLE ratemanagement.pricelist_items ADD COLUMN attempt_fee numeric NOT NULL DEFAULT 0.0;

      -- routing call profile carries the snapshots to the switch (alongside destination_fee/dialpeer_fee)
      ALTER TYPE switch22.callprofile_ty
        ADD ATTRIBUTE destination_attempt_fee numeric,
        ADD ATTRIBUTE dialpeer_attempt_fee numeric;

      -- register the new profile fields in the switch interface so the switch echoes them
      -- back into the CDR. The "custom" column is exposed as "forcdr" by load_interface_out(),
      -- so custom=true means the field is included in the CDR dynamic data — exactly how
      -- destination_fee (id 721, rank 1780) and dialpeer_fee (id 723, rank 1800) work.
      INSERT INTO switch22.switch_interface_out (id, name, type, custom, rank, for_radius)
        VALUES (1059, 'destination_attempt_fee', 'numeric', true, 1996, true);
      INSERT INTO switch22.switch_interface_out (id, name, type, custom, rank, for_radius)
        VALUES (1060, 'dialpeer_attempt_fee', 'numeric', true, 1997, true);

      -- batch settlement record type (alongside destination_fee/dialpeer_fee)
      ALTER TYPE billing.cdr_v2
        ADD ATTRIBUTE destination_attempt_fee numeric,
        ADD ATTRIBUTE dialpeer_attempt_fee numeric;
    }
  end

  def down
    execute %q{
      ALTER TYPE billing.cdr_v2
        DROP ATTRIBUTE destination_attempt_fee,
        DROP ATTRIBUTE dialpeer_attempt_fee;
      DELETE FROM switch22.switch_interface_out WHERE name IN ('destination_attempt_fee', 'dialpeer_attempt_fee');
      ALTER TYPE switch22.callprofile_ty
        DROP ATTRIBUTE destination_attempt_fee,
        DROP ATTRIBUTE dialpeer_attempt_fee;
      ALTER TABLE ratemanagement.pricelist_items DROP COLUMN attempt_fee;
      ALTER TABLE data_import.import_dialpeers DROP COLUMN attempt_fee;
      ALTER TABLE data_import.import_destinations DROP COLUMN attempt_fee;
      ALTER TABLE class4.dialpeer_next_rates DROP COLUMN attempt_fee;
      ALTER TABLE class4.destination_next_rates DROP COLUMN attempt_fee;
      ALTER TABLE class4.dialpeers DROP COLUMN attempt_fee;
      ALTER TABLE class4.destinations DROP COLUMN attempt_fee;
    }
  end
end
