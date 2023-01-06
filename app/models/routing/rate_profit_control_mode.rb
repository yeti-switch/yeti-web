# frozen_string_literal: true

class Routing::RateProfitControlMode
  MODE_DISABLED = 1
  MODE_PER_CALL = 2
  MODES = {
    MODE_DISABLED => 'Disabled',
    MODE_PER_CALL => 'Per call'
  }.freeze
end
