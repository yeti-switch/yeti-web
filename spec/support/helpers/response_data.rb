module Helpers
  module ResponseData
    def response_data
      JSON.parse(response.body)['data']
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::ResponseData
end
