class AddBalanceBeforePaymentField < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :balance_before_payment, :numeric
  end
end
