# frozen_string_literal: true

require 'jsonapi/exceptions/authorization_failed'
require 'jsonapi/exceptions/authentication_failed'
require 'jsonapi/operation_dispatcher_patch'
require 'jsonapi/relationship_patch'
require 'jsonapi/request_parser_patch'

# Fix Rack deprecation: :unprocessable_entity -> :unprocessable_content (HTTP 422)
# https://github.com/cerebris/jsonapi-resources/issues/1456
module JSONAPI
  module Exceptions
    class ValidationErrors < Error
      private

      def json_api_error(attr_key, message)
        create_error_object(code: JSONAPI::VALIDATION_ERROR,
                            status: :unprocessable_content,
                            title: message,
                            detail: detail(attr_key, message),
                            source: { pointer: pointer(attr_key) },
                            meta: metadata_for(attr_key, message))
      end
    end

    class SaveFailed < Error
      def errors
        [create_error_object(code: JSONAPI::SAVE_FAILED,
                             status: :unprocessable_content,
                             title: I18n.translate('jsonapi-resources.exceptions.save_failed.title',
                                                   default: 'Save failed or was cancelled'),
                             detail: I18n.translate('jsonapi-resources.exceptions.save_failed.detail',
                                                    default: 'Save failed or was cancelled'))]
      end
    end
  end
end

JSONAPI.configure do |config|
  # can be paged, offset, none (default)
  config.default_paginator = :none
  config.default_page_size = 50
  config.maximum_page_size = 1_000
  config.top_level_meta_include_record_count = true
  config.top_level_meta_record_count_key = :total_count
end
