# frozen_string_literal: true

module JSONAPI
  module Exceptions
    class AuthorizationFailed < Error
      def errors
        [create_error_object(code: '401',
                             status: :unauthorized,
                             title: I18n.translate('jsonapi-resources.exceptions.not_authorized.title',
                                                   default: 'Authorization failed'),
                             detail: I18n.translate('jsonapi-resources.exceptions.not_authorized.detail',
                                                    default: 'Authorization token expired or incorrect.'))]
      end
    end
  end
end
