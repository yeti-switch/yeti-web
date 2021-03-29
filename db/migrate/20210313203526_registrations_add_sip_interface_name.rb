class RegistrationsAddSipInterfaceName < ActiveRecord::Migration[5.2]
  def change
    add_column 'class4.registrations', :sip_interface_name, :string
  end
end
