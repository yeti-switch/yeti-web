# frozen_string_literal: true

Cryptomus.configure do |config|
  config.merchant_id = YetiConfig.cryptomus&.merchant_id
  config.api_key = YetiConfig.cryptomus&.api_key
end
