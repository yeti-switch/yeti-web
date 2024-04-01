class AddDisconnectCode146 < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      INSERT INTO class4.disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (146, 1, true, false, 487, 'Canceled before routing completed', NULL, NULL, false, false, true, false);
    }
  end

  def down
    execute %q{
      delete from class4.disconnect_code where id in(146);
    }
  end
end
