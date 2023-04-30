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

  self.import_attributes = %w[name profit_control_mode_id]

  import_for Routing::Rateplan

  def profit_control_mode_display_name
    profit_control_mode_id.nil? ? 'nil' : Routing::RateProfitControlMode::MODES[rate_policy_id]
  end

  def self.after_import_hook
    resolve_integer_constant('profit_control_mode_id', 'profit_control_mode_name', Routing::RateProfitControlMode::MODES)
    super
  end
end
