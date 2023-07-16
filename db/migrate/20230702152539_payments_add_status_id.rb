class PaymentsAddStatusId < ActiveRecord::Migration[7.0]
  def up
    # Payment::CONST::STATUS_ID_COMPLETED == 20
    add_column 'billing.payments', :status_id, :integer, limit: 2, default: 20, null: false
    change_column_default 'billing.payments', :status_id, nil
  end

  def down
    remove_column 'billing.payments', :status_id
  end
end
