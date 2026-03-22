# frozen_string_literal: true

class DisconnectCode144 < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      INSERT INTO class4.disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (144, 1, true, false, 500, 'Media stream exception', NULL, 'Media stream exception', false, false, true, false);
    }
  end

  def down
    execute %q{
      DELETE FROM class4.disconnect_code WHERE id = 144;
    }
  end
end
