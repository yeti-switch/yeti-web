# frozen_string_literal: true

require 'net/http'

module Worker
  class PingCallbackUrlJob < ::ApplicationJob
    class TryAgainError < RuntimeError
    end

    queue_as 'ping_callback_url'

    def perform(callback_url, params)
      # ping & try again if something went wrong
      url = URI.parse(callback_url)
      req = Net::HTTP::Get.new(url.to_s)
      req.set_form_data(params)
      res = Net::HTTP.start(
        url.host,
        url.port,
        use_ssl: url.scheme == 'https',
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        http.request(req)
      end
      unless res.code.to_i == 200
        message = "Response code: #{res.code}\n"
        message += res.read_body.to_s[0..500] if res.class.body_permitted?
        raise TryAgainError, message
      end
    end
  end
end
