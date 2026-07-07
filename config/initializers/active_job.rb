# frozen_string_literal: true

# Enqueue jobs immediately rather than after the surrounding DB transaction commits.
# Set on the base class (not via config.active_job) because the global config is
# deprecated in Rails 8.1.
ActiveSupport.on_load(:active_job) do
  self.enqueue_after_transaction_commit = false
end
