# frozen_string_literal: true

class HttpSender
  class TimeoutError < StandardError
    def initialize(url)
      super("HTTP Timeout #{url}")
    end
  end

  class Error < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
      super("HTTP Error #{response.code} #{response.message}\n#{response.body}")
    end
  end

  TIMEOUT = 60
  CONTENT_TYPE_JSON = 'application/json'

  def initialize(url:, content_type:, body:)
    @url = url
    @content_type = content_type
    @body = body
  end

  # @raise [HttpSender::Error,HttpSender::TimeoutError]
  def send_request
    response = HTTParty.post(url, build_options)
    raise Error, response if request_failed?(response)
  rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout => _e
    raise TimeoutError, url
  end

  private

  attr_reader :url, :content_type, :body

  def build_options
    { body: body, headers: { 'Content-Type' => content_type }, timeout: TIMEOUT, verify: false }
  end

  def request_failed?(response)
    response.code < 200 || response.code >= 400
  end
end
