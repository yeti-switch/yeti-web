# frozen_string_literal: true

module OperationDispatcherPatch
  def with_default_handling
    # remove exceptions handling - exceptions will be propagated to controller level
    yield
  end
end

JSONAPI::OperationDispatcher.prepend(OperationDispatcherPatch)
