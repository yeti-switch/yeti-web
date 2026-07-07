# frozen_string_literal: true

# Support callable/symbolic filter defaults.
#
# JSONAPI::Request#parse_filters (0.10/26.x; was RequestParser#set_default_filters
# in 0.9) only assigns static default values. This patch resolves a filter's
# `default:` when it is a Proc (called with params/context) or a Symbol (sent to
# the resource class), so resources can compute defaults at request time.
module JsonapiRequestPatch
  def parse_filters(resource_klass, filters)
    parsed = super

    resource_klass._allowed_filters.each do |filter, opts|
      default = opts[:default]
      next if default.nil?

      # `super` assigns the raw default only when the request did not supply the
      # filter; resolve just those (identity/equality with the raw default).
      next unless parsed[filter].equal?(default) || parsed[filter] == default

      value =
        case default
        when Proc
          default.call({ params:, context: })
        when Symbol
          resource_klass.public_send(default, { params:, context: })
        else
          default
        end

      if value.nil?
        parsed.delete(filter)
      else
        parsed[filter] = value
      end
    end

    parsed
  end
end

JSONAPI::Request.prepend(JsonapiRequestPatch)
