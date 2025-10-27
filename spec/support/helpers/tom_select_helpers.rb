# frozen_string_literal: true

module Helpers
  module TomSelectHelpers
    def tom_select(option_id, from:, search_query:)
      if from.start_with?('#')
        execute_script %(document.querySelector("#{from}").tomselect.on('load', () => { document.querySelector("#{from}").tomselect.setValue(#{option_id}) });)
        execute_script %(document.querySelector("#{from}").tomselect.load('#{search_query}');)
        Timeout.timeout(Capybara.default_max_wait_time) do
          loop do
            value = evaluate_script("document.querySelector('#{from}').tomselect.getValue()")
            break if value.to_s == option_id.to_s

            sleep 0.1
          end
        end
      elsif from.start_with?('.')
        execute_script %(document.getElementsByClassName("#{from.slice(1, from.length)}").tomselect.on('load', () => { document.querySelector("#{from.slice(1, from.length)}").tomselect.setValue(#{option_id}) });)
        execute_script %(document.getElementsByClassName("#{from.slice(1, from.length)}").tomselect.load('#{search_query}');)
        Timeout.timeout(Capybara.default_max_wait_time) do
          loop do
            value = evaluate_script("document.getElementsByClassName('#{from.slice(1, from.length)}').tomselect.getValue()")
            break if value.to_s == option_id.to_s

            sleep 0.1
          end
        end
      end
    end
  end
end
