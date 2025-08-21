class FixGatewaysImport < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table data_import.import_gateways
        drop column orig_append_headers_req,
        drop column term_append_headers_req;
    }
  end

  def down
    execute %q{
      alter table data_import.import_gateways
        add orig_append_headers_req varchar,
        add term_append_headers_req varchar;
    }
  end
end
