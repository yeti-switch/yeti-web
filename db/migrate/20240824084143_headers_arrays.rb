class HeadersArrays < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table class4.gateways
        alter column orig_append_headers_req  type varchar[] using string_to_array(replace(orig_append_headers_req,' ',''), '\r\n'),
        alter column term_append_headers_req  type varchar[] using string_to_array(replace(orig_append_headers_req,' ',''), '\r\n');
    }
  end

  def down
    execute %q{
      alter table class4.gateways
        alter column orig_append_headers_req  type varchar using array_to_string(orig_append_headers_req, '\r\n'),
        alter column term_append_headers_req  type varchar using array_to_string(orig_append_headers_req, '\r\n');
    }
  end
end
