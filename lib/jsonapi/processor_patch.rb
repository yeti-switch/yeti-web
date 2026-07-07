# frozen_string_literal: true

# Propagate exceptions to the controller level instead of turning JSONAPI
# errors into an ErrorsOperationResult inside the processor (the gem default,
# see JSONAPI::Processor#process). The controller's #handle_exceptions renders
# the JSON:API error document and reports non-JSONAPI errors.
#
# In jsonapi-resources 0.9 this lived in OperationDispatcher#with_default_handling;
# the 0.10/26.x rewrite moved the rescue into JSONAPI::Processor#process.
module ProcessorPatch
  def process
    run_callbacks :operation do
      run_callbacks operation_type do
        @result = send(operation_type)
      end
    end
  end
end

JSONAPI::Processor.prepend(ProcessorPatch)
