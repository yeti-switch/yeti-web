# == Schema Information
#
# Table name: cdr_exports
#
#  id           :integer          not null, primary key
#  status       :string           not null
#  fields       :string           default([]), not null, is an Array
#  filters      :json             not null
#  callback_url :string
#  type         :string           not null
#  created_at   :datetime
#  updated_at   :datetime
#

class CdrExport::Base < ::CdrExport
end
