# frozen_string_literal: true

require 'aws-sdk-s3'

if YetiConfig.s3_storage&.endpoint&.present?
  Aws.config.update(
    {
      endpoint: YetiConfig.s3_storage.endpoint,
      access_key_id: YetiConfig.s3_storage.access_key_id,
      secret_access_key: YetiConfig.s3_storage.secret_access_key,
      region: YetiConfig.s3_storage.region,
      force_path_style: YetiConfig.s3_storage.force_path_style
    }
  )
end
