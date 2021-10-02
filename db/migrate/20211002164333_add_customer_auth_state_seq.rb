class AddCustomerAuthStateSeq < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE SEQUENCE class4.customers_auth_state_seq
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE class4.customers_auth_state_seq
    SQL
  end
end
