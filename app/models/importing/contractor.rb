# == Schema Information
#
# Table name: data_import.import_contractors
#
#  id                   :integer          not null, primary key
#  o_id                 :integer
#  name                 :string
#  vendor               :boolean
#  customer             :boolean
#  enabled              :boolean
#  error_string         :string
#  description          :string
#  address              :string
#  phones               :string
#  smtp_connection_id   :integer
#  smtp_connection_name :string
#

class Importing::Contractor  < Importing::Base
  self.table_name = 'data_import.import_contractors'
  attr_accessor :file

  belongs_to :smtp_connection, class_name: 'System::SmtpConnection'

  self.import_attributes = ['enabled', 'name', 'vendor', 'customer', 'smtp_connection_id']

  self.import_class = ::Contractor

end
