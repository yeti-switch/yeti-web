# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.

# Parameters that are never filtered, even when they match one of the rules below. Matched
# in full, so `batch_key` is an exception while `batch_key_confirmation` would not be.
#
# `batch_key` is a comma separated list of dialled numbers, split into one numberlist item
# per entry by Routing::NumberlistItem#batch_key - the same data as `key`, that no rule
# matches either. Only `_key` makes it look like a credential.
UNFILTERED_PARAMS = %w[
  batch_key
].freeze

# Matched partially: `passw` covers `password`, `_key` covers `api_key`.
FILTERED_PARAMS = %w[
  passw secret token _key crypt salt certificate otp ssn
].freeze

# ActiveSupport::ParameterFilter has no exception list of its own: it compiles every
# string filter into a single regexp and replaces the value of a key that matches it
# before consulting anything else, so a later rule cannot put a value back. The exceptions
# are therefore a negative lookahead in front of the rules, and apply to the rules
# declared here only - the ones Doorkeeper appends (`code`, `state`, `nonce`, the token
# names) are separate entries of config.filter_parameters and are not guarded by it.
Rails.application.config.filter_parameters += [
  /\A(?!(?:#{Regexp.union(UNFILTERED_PARAMS).source})\z).*(?:#{Regexp.union(FILTERED_PARAMS).source})/i
]
