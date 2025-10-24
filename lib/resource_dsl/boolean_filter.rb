# frozen_string_literal: true

module ResourceDSL
  module BooleanFilter
    COLLECTION = [
      ['Yes', true].freeze,
      ['No', false].freeze
    ]

    def boolean_filter(name, options = {})
      options = options.merge(as: :tom_select, collection: COLLECTION)
      options[:input_html] ||= {}
      if name.is_a?(Symbol)
        options[:label] ||= "#{name.to_s.humanize}?"
      elsif name.is_a?(String)
        options[:label] ||= "#{name.humanize}?"
      end

      filter name, options
    end
  end
end
