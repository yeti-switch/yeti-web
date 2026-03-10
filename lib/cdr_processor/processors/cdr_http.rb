# frozen_string_literal: true

module CdrProcessor
  module Processors
    class CdrHttp < CdrProcessor::Processors::CdrHttpBase
      @consumer_name = 'cdr_http'

      private

      def http_method
        @params['method'].downcase.to_sym
      end

      def http_headers
        if http_method == :get
          {}
        else
          { 'content-type' => 'application/json', 'accept' => 'application/json' }
        end
      end
    end
  end
end
