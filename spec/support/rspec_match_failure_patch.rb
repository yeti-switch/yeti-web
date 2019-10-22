# frozen_string_literal: true

# Prevents expectation failure message truncation
# by setting max_formatted_output_length=nil for default formatter.
# @see RSpec::Support::ObjectFormatter#format
RSpec::Support::ObjectFormatter.instance_variable_set(
  :@default_instance,
  RSpec::Support::ObjectFormatter.new(nil)
)
