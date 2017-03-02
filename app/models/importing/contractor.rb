# == Schema Information
#
# Table name: data_import.import_contractors
#
#  id           :integer          not null, primary key
#  o_id         :integer
#  name         :string
#  vendor       :boolean
#  customer     :boolean
#  enabled      :boolean
#  error_string :string
#  description  :string
#  address      :string
#  phones       :string
#  tech_contact :string
#  fin_contact  :string
#

class Importing::Contractor  < Importing::Base
    self.table_name = 'data_import.import_contractors'
    attr_accessor :file

    self.import_attributes = ['enabled', 'name', 'vendor', 'customer']

    self.import_class = ::Contractor

end
