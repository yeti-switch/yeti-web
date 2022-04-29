class Add607608Codes < ActiveRecord::Migration[6.1]
  def up
    execute %q{
INSERT INTO class4.disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop)
 VALUES (1602, 2, false, true, 607, 'Unwanted', NULL, NULL, false, false, true, false);
INSERT INTO class4.disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop)
 VALUES (1603, 2, false, true, 608, 'Rejected', NULL, NULL, false, false, true, false);

            }
  end
  def down
    execute %q{
    delete from class4.disconnect_code where id in (1602,1603);
            }
  end
end
