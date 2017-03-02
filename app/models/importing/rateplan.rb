# == Schema Information
#
# Table name: import_rateplans
#
#  id           :integer          not null, primary key
#  o_id         :integer
#  name         :string
#  error_string :string
#

class Importing::Rateplan < Importing::Base
  self.table_name = 'import_rateplans'

  self.import_attributes = ['name']
  self.import_class = ::Rateplan

end
