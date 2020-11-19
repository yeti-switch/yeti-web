# frozen_string_literal: true

module AdvisoryLock
  class Cdr < PgAdvisoryLock::Base
    sql_caller_class 'SqlCaller::Cdr'

    # AdvisoryLock::Cdr.with_lock(:invoice, id: account.id) { ... }
    register_lock :invoice, -1_000
  end
end
