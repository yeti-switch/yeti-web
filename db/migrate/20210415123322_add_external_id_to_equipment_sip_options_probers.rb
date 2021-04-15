class AddExternalIdToEquipmentSipOptionsProbers < ActiveRecord::Migration[5.2]
  def change
    add_column 'class4.sip_options_probers', :external_id, :bigint
  end
end
