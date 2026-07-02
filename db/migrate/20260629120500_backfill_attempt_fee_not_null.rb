# frozen_string_literal: true

class BackfillAttemptFeeNotNull < ActiveRecord::Migration[7.2]
  # Companion to AddAttemptFee. The column was added to the large class4.destinations
  # and class4.dialpeers tables as plain NULLable (instant). Here we backfill existing
  # rows to 0 and enforce DEFAULT 0.0 + NOT NULL — the heavier work, kept in its own
  # migration so it can be run deliberately.
  def up
    execute %q{
      UPDATE class4.destinations SET attempt_fee = 0 WHERE attempt_fee IS NULL;
      ALTER TABLE class4.destinations ALTER COLUMN attempt_fee SET DEFAULT 0.0;
      ALTER TABLE class4.destinations ALTER COLUMN attempt_fee SET NOT NULL;

      UPDATE class4.dialpeers SET attempt_fee = 0 WHERE attempt_fee IS NULL;
      ALTER TABLE class4.dialpeers ALTER COLUMN attempt_fee SET DEFAULT 0.0;
      ALTER TABLE class4.dialpeers ALTER COLUMN attempt_fee SET NOT NULL;
    }
  end

  def down
    execute %q{
      ALTER TABLE class4.dialpeers ALTER COLUMN attempt_fee DROP NOT NULL;
      ALTER TABLE class4.dialpeers ALTER COLUMN attempt_fee DROP DEFAULT;
      ALTER TABLE class4.destinations ALTER COLUMN attempt_fee DROP NOT NULL;
      ALTER TABLE class4.destinations ALTER COLUMN attempt_fee DROP DEFAULT;
    }
  end
end
