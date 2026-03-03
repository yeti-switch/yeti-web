# frozen_string_literal: true

# Parses SIP/SIPS/TEL URI strings into a hash matching the switch22.uri_ty database type.
#
# Supported formats:
#   "Display Name" <sip:user@host:port;uri-param?uri-header>;header-param
#   <sip:user@host:port;uri-param>
#   sip:user@host:port;uri-param
#   tel:+1234567890;param
#
# Returns a hash with keys:
#   s       - String, schema (sip, sips, tel)
#   n       - String, display name
#   u       - String, URI userpart
#   h       - String, host
#   p       - Integer, port
#   up_arr  - String[], URI parameters
#   uh_arr  - String[], URI headers
#   np_arr  - String[], header parameters
class SipUriParser
  # Parses a single SIP URI string. Returns a hash or nil for blank input.
  def self.parse(input)
    new(input).parse
  end

  # Parses a comma-separated list of SIP URIs.
  # Returns an array of parsed hashes, or nil for blank input.
  def self.parse_multiple(input)
    input = input.to_s.strip
    return nil if input.empty?

    split_uris(input).map { |uri| new(uri).parse }.compact
  end

  # Splits a comma-separated header value respecting angle brackets.
  # Commas inside <...> are not treated as separators.
  def self.split_uris(input)
    uris = []
    current = +''
    depth = 0

    input.each_char do |char|
      case char
      when '<'
        depth += 1
        current << char
      when '>'
        depth -= 1
        current << char
      when ','
        if depth.zero?
          uris << current.strip
          current = +''
        else
          current << char
        end
      else
        current << char
      end
    end

    uris << current.strip unless current.strip.empty?
    uris
  end
  private_class_method :split_uris

  def initialize(input)
    @input = input.to_s.strip
  end

  def parse
    return nil if @input.empty?

    @result = { 's' => nil, 'n' => nil, 'u' => nil, 'h' => nil, 'p' => nil,
                'up_arr' => [], 'uh_arr' => [], 'np_arr' => [] }

    remaining = @input

    if remaining.include?('<')
      remaining = extract_bracketed_parts(remaining)
    end

    parse_uri(remaining)

    @result
  end

  private

  # Extracts display name (before <), header params (after >),
  # and returns the URI part (inside < >).
  def extract_bracketed_parts(str)
    display_part, rest = str.split('<', 2)
    uri_part, header_params_part = rest.split('>', 2)

    @result['n'] = parse_display_name(display_part)

    if header_params_part && !header_params_part.strip.empty?
      @result['np_arr'] = split_params(header_params_part)
    end

    uri_part.strip
  end

  def parse_display_name(part)
    part = part.strip
    return nil if part.empty?

    if part.start_with?('"') && part.end_with?('"')
      part[1..-2]
    else
      part
    end
  end

  def parse_uri(uri)
    # Extract scheme
    if uri =~ /\A(sips?|tel):/i
      @result['s'] = Regexp.last_match(1).downcase
      uri = uri.sub(/\A#{Regexp.last_match(1)}:/i, '')
    end

    if @result['s'] == 'tel'
      parse_tel_uri(uri)
    else
      parse_sip_uri(uri)
    end
  end

  def parse_tel_uri(uri)
    user_part, *param_parts = uri.split(';')
    @result['u'] = user_part
    @result['up_arr'] = param_parts.reject(&:empty?)
  end

  def parse_sip_uri(uri)
    # Split off URI headers (after ?)
    uri_without_headers, headers_part = uri.split('?', 2)
    if headers_part
      @result['uh_arr'] = headers_part.split('&').map(&:strip).reject(&:empty?)
    end

    # Separate user from host
    if uri_without_headers.include?('@')
      user_part, host_part = uri_without_headers.split('@', 2)
      @result['u'] = user_part
    else
      host_part = uri_without_headers
    end

    # Split host part by ; to extract URI params
    segments = host_part.split(';')
    host_and_port = segments.shift
    @result['up_arr'] = segments.reject(&:empty?)

    parse_host_port(host_and_port)
  end

  def parse_host_port(str)
    return if str.blank?

    # Handle IPv6: [::1]:5060 or [::1]
    if str.start_with?('[')
      if str =~ /\A\[([^\]]+)\]:(\d+)\z/
        @result['h'] = Regexp.last_match(1)
        @result['p'] = Regexp.last_match(2).to_i
      elsif str =~ /\A\[([^\]]+)\]\z/
        @result['h'] = Regexp.last_match(1)
      end
    else
      host, port = str.split(':', 2)
      @result['h'] = host unless host.empty?
      @result['p'] = port.to_i if port.present?
    end
  end

  def split_params(str)
    str.sub(/\A\s*;/, '').split(';').map(&:strip).reject(&:empty?)
  end
end
