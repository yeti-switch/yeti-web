# frozen_string_literal: true

# == Schema Information
#
# Table name: import_rateplans
#
#  id                       :integer          not null, primary key
#  o_id                     :integer
#  name                     :string
#  error_string             :string
#  profit_control_mode_id   :integer
#  profit_control_mode_name :string
#  is_changed               :boolean
#

class Importing::Rateplan < Importing::Base
  self.table_name = 'import_rateplans'

  belongs_to :profit_control_mode, class_name: 'Routing::RateProfitControlMode'

  self.import_attributes = %w[name profit_control_mode_id]

  self.import_class = ::Rateplan
end
