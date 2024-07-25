class LegbRtpTimeout < ActiveRecord::Migration[7.0]
  def up
    execute %q{

      INSERT INTO class4.disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop)
      VALUES (132, 1, true, false, 200, 'Rtp timeout(legB)', NULL, NULL, false, true, true, false);
      update class4.disconnect_code set rewrited_reason = NULL where id=125 and rewrited_reason='';
    }
  end

  def down
    execute %q{

      delete from class4.disconnect_code where id=132;
      update class4.disconnect_code set rewrited_reason='' where id=125 and rewrited_reason is null;
    }
  end

end
