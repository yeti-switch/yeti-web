# frozen_string_literal: true

Cryptomus.configure do |config|
  config.merchant_id = YetiConfig.cryptomus&.merchant_id
  config.api_key = YetiConfig.cryptomus&.api_key
  config.base_url = YetiConfig.cryptomus&.base_url.presence || Cryptomus::CONST::URL
end
