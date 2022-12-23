class AddAccountIdToCdrExports < ActiveRecord::Migration[6.1]
  def change
    add_reference 'sys.cdr_exports', :customer_account, foreign_key: { to_table: 'billing.accounts' }, type: :integer, index: true
    add_column 'sys.cdr_exports', :uuid, :uuid, null: false, default: 'public.uuid_generate_v1()'
    add_index 'sys.cdr_exports', :uuid, unique: true
  end
end
