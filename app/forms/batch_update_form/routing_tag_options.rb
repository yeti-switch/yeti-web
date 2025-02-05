# frozen_string_literal: true

module BatchUpdateForm::RoutingTagOptions
  extend ActiveSupport::Concern

  class_methods do
    def add_foreign_key_additional_options(result, options)
      additional_options = options[:additional_options]
      # Expect additional_options to be an array of hashes, for example:
      #   [{ label: 'Any tag', value: nil }]
      additional_options.each do |opt|
        # Prepend each additional option to the result array.
        # Each item is represented as [label, value].
        result.prepend([opt[:label], opt[:value]])
      end

      result
    end
  end
end
