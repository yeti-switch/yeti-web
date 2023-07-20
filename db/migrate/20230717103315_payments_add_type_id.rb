class PaymentsAddTypeId < ActiveRecord::Migration[7.0]
  def change
    # Payment::CONST::STATUS_ID_COMPLETED == 20
    change_column_default 'billing.payments', :status_id, 20

    # Payment::CONST::TYPE_ID_MANUAL == 20
    add_column 'billing.payments', :type_id, :integer, default: 20, limit: 2, null: false

    # Payment::CONST::TYPE_ID_CRYPTOMUS == 10
    # Payment::CONST::STATUS_ID_PENDING == 30
    execute 'UPDATE billing.payments SET type_id = 10 WHERE status_id = 30'
  end

  def down
    remove_column 'billing.payments', :type_id
    change_column_default 'billing.payments', :status_id, nil
  end
end
