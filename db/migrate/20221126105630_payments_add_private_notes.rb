class PaymentsAddPrivateNotes < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table billing.payments add private_notes varchar;
      update billing.payments set private_notes=notes;
      update billing.payments set notes=null;
    }
  end
  def down
    execute %q{
      update billing.payments set notes=private_notes;
      alter table billing.payments drop column private_notes;
    }
  end
end
