# frozen_string_literal: true

# == Schema Information
#
# Table name: import_rateplans
#
#  id                       :bigint(8)        not null, primary key
#  error_string             :string
#  is_changed               :boolean
#  name                     :string
#  profit_control_mode_name :string
#  o_id                     :integer(4)
#  profit_control_mode_id   :integer(4)
#

class Importing::Rateplan < Importing::Base
  self.table_name = 'import_rateplans'

  belongs_to :profit_control_mode, class_name: 'Routing::RateProfitControlMode', optional: true

  self.import_attributes = %w[name profit_control_mode_id]

  import_for Routing::Rateplan
end
