# frozen_string_literal: true

# Whether an optional shell hook is configured, for collectors that seed their counters with a zero
# value at process start.
#
# Seeding exists so that an alert on "the hook has not run" has a series to evaluate against from
# the moment the exporter starts. That reasoning only holds where the hook exists: on an
# installation that never configured one, the seeded zeros describe a feature that is switched off,
# and such an alert would fire forever against a hook nobody asked for.
module HookConfig
  module_function

  # @param name [Symbol] the YetiConfig key holding the hook command
  # @return [Boolean] false when the key is unset, or when YetiConfig is unavailable
  def configured?(name)
    YetiConfig.public_send(name).present?
  rescue StandardError => e
    # YetiConfig is absent when config/yeti_web.yml could not be loaded (see YetiConfigLoader).
    # Without it we cannot tell a configured hook from an absent one; not seeding is the quieter
    # of the two guesses.
    warn "HookConfig: #{e.class} #{e.message}"
    false
  end
end
