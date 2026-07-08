# frozen_string_literal: true

# Applies an optional outbound HTTP proxy to an HTTPX client, driven by two
# settings read from any config source (a YetiConfig section, a params hash,
# etc.):
#   http_proxy    - explicit proxy URI; always wins when present.
#   use_env_proxy - when true (and http_proxy is unset), honour the standard
#                   HTTP(S)_PROXY env vars.
# With neither set, requests go direct regardless of any proxy env vars present
# on the host (e.g. HTTPS_PROXY on CI).
#
# HTTPX auto-loads its proxy plugin whenever a HTTP(S)_PROXY env var is set and,
# at request time, that env proxy takes precedence over anything we configure,
# with no per-session opt-out. So unless we want to inherit the env proxy, we
# hide those vars for the duration of the request (see #run), leaving only the
# configured proxy (or none) in effect.
#
# Usage:
#   proxy = HttpxProxy.new(http_proxy: cfg.http_proxy, use_env_proxy: cfg.use_env_proxy)
#   http  = proxy.apply(HTTPX.with(...))
#   proxy.run { http.get(url) }
class HttpxProxy
  # Standard proxy env vars HTTPX consults via URI#find_proxy.
  ENV_VARS = %w[http_proxy HTTP_PROXY https_proxy HTTPS_PROXY].freeze

  # @param http_proxy [String, nil] explicit proxy URI.
  # @param use_env_proxy [Boolean, nil] honour HTTP(S)_PROXY env vars.
  def initialize(http_proxy: nil, use_env_proxy: nil)
    @http_proxy = http_proxy.presence
    @use_env_proxy = use_env_proxy || false
  end

  # Adds the configured proxy to an HTTPX session (no-op when unset).
  # @param session [HTTPX::Session]
  # @return [HTTPX::Session]
  def apply(session)
    return session if @http_proxy.blank?

    session.plugin(:proxy).with_proxy(uri: @http_proxy)
  end

  # Runs the request block with the right env-proxy behaviour.
  def run(&)
    return yield if inherit_env_proxy?

    without_env_proxy(&)
  end

  # Honour HTTP(S)_PROXY env vars only when explicitly enabled and no explicit
  # proxy is configured (a configured proxy always wins).
  def inherit_env_proxy?
    @http_proxy.blank? && @use_env_proxy
  end

  private

  def without_env_proxy
    saved = ENV_VARS.index_with { |name| ENV.fetch(name, nil) }
    ENV_VARS.each { |name| ENV.delete(name) }
    yield
  ensure
    saved.each { |name, value| value.nil? ? ENV.delete(name) : ENV[name] = value }
  end
end
