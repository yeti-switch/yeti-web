# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr_exports
#
#  id           :integer(4)       not null, primary key
#  callback_url :string
#  fields       :string           default([]), not null, is an Array
#  filters      :json             not null
#  rows_count   :integer(4)
#  status       :string           not null
#  type         :string           not null
#  created_at   :datetime
#  updated_at   :datetime
#

class CdrExport::Base < ::CdrExport
  def self.policy_class
    CdrExportPolicy
  end
end
