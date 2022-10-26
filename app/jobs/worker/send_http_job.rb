# frozen_string_literal: true

module Worker
  class SendHttpJob < ::ApplicationJob
    queue_as 'send_http'

    def perform(url, content_type, body)
      HttpSender.new(url: url, content_type: content_type, body: body).send_request
    end
  end
end
