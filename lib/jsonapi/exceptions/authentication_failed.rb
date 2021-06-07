# frozen_string_literal: true

module JSONAPI
  module Exceptions
    class AuthenticationFailed < Error
      def errors
        [
          create_error_object(
            code: '401',
            status: :unauthorized,
            title: I18n.translate(
              'jsonapi-resources.exceptions.not_authenticated.title',
              default: 'Authentication failed'
            ),
            detail: I18n.translate(
              'jsonapi-resources.exceptions.not_authenticated.detail',
              default: 'Incorrect login or password.'
            )
          )
        ]
      end
    end
  end
end
