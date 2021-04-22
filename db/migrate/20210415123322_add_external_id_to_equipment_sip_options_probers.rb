class AddExternalIdToEquipmentSipOptionsProbers < ActiveRecord::Migration[5.2]
  def change
    add_column 'class4.sip_options_probers', :external_id, :bigint
    add_index 'class4.sip_options_probers', :external_id, unique: true
  end
end
