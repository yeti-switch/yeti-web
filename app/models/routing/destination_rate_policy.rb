# frozen_string_literal: true

class Routing::DestinationRatePolicy
  POLICY_FIXED = 1
  POLICY_DP = 2
  POLICY_MIN = 3
  POLICY_MAX = 4
  POLICIES = {
    POLICY_FIXED => 'Fixed',
    POLICY_DP => 'Based on used dialpeer',
    POLICY_MIN => 'MIN(Fixed,Based on used dialpeer)',
    POLICY_MAX => 'MAX(Fixed,Based on used dialpeer)'
  }.freeze

  POLICIES_CDR = {
    POLICY_FIXED => 'Fixed',
    POLICY_DP => 'Dp',
    POLICY_MIN => 'Min',
    POLICY_MAX => 'Max'
  }.freeze

  POLICIES_COLORS = {
    POLICY_FIXED => 'green',
    POLICY_DP => 'orange',
    POLICY_MIN => 'blue',
    POLICY_MAX => 'red'
  }.freeze
end
