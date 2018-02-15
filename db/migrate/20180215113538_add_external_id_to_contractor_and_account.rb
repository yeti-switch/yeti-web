class AddExternalIdToContractorAndAccount < ActiveRecord::Migration
  def change
    add_column :contractors, :external_id, :bigint
    add_column :accounts, :external_id, :bigint
    add_index :accounts, :external_id, unique: true, name: 'accounts_external_id_idx'
    add_index :contractors, :external_id, unique: true, name: 'contractors_external_id_idx'
  end
end
