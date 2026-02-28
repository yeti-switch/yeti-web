# frozen_string_literal: true

module ResourceDSL
  module BooleanFilter
    COLLECTION = [
      ['Yes', true].freeze,
      ['No', false].freeze
    ].freeze

    def boolean_filter(name, options = {})
      options = options.merge(as: :select, collection: COLLECTION)
      options[:input_html] ||= {}
      options[:input_html][:class] = ['tom-select', options[:input_html][:class]].compact.join(' ')
      options[:input_html][:'data-skip-dropdown-input'] = true

      filter name, options
    end
  end
end
