# frozen_string_literal: true

module AdvisoryLock
  class Yeti < ::PgAdvisoryLock::Base
    sql_caller_class 'SqlCaller::Yeti'

    # Values should be within bigint -9223372036854775808 to +9223372036854775807.
    register_lock :rate_management, -2_000
  end
end
