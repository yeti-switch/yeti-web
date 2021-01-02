# frozen_string_literal: true

require 'rest-client'
require_relative 'cdr_http_base'

class CdrHttp < CdrHttpBase
  @consumer_name = 'cdr_http'

  private

  def http_body(event)
    if http_method == :get
      { params: event }
    else
      event.to_json
    end
  end

  def http_method
    @params['method'].downcase.to_sym
  end

  def http_headers
    if http_method == :get
      {}
    else
      { content_type: :json, accept: :json }
    end
  end
end
