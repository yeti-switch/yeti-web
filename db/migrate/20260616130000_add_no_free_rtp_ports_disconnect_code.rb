# frozen_string_literal: true

class AddNoFreeRtpPortsDisconnectCode < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      INSERT INTO class4.disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop)
      VALUES (134, 1, true, false, 500, 'No Free RTP ports', NULL, NULL, false, false, true, false);
    }
  end

  def down
    execute %q{
      DELETE FROM class4.disconnect_code WHERE id = 134;
    }
  end
end
