# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.sip_schemas
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class System::SipSchema < Yeti::ActiveRecord
  self.table_name = 'sys.sip_schemas'
end
