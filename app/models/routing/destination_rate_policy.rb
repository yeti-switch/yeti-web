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
end
