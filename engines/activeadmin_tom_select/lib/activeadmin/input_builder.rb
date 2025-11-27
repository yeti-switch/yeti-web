# frozen_string_literal: true

module ActiveAdmin
  # Helper class to build input options from block DSL
  class InputBuilder
    def initialize(options = {})
      @options = options.dup
      @ajax_resource = nil
      @ajax_params = {}
      @ajax_extra = {}
    end

    # Usage: as :tom_select
    def as(value)
      @options[:as] = value
    end

    # Usage: ajax resource: 'Contractor'
    # Also supports additional keys: ajax foo: 'bar'
    def ajax(resource: nil, **extra)
      @ajax_resource = resource if resource
      @ajax_extra.merge!(extra) unless extra.empty?
    end

    # Usage: ajax_params q: { customer_eq: true }
    def ajax_params(params)
      raise ArgumentError, 'ajax_params expects a Hash' unless params.is_a?(Hash)

      @ajax_params = deep_merge_hashes(@ajax_params, params)
    end

    # Usage: label 'Customer Name'
    def label(text)
      @options[:label] = text
    end

    # Usage: hint 'Select a contractor'
    def hint(text)
      @options[:hint] = text
    end

    # Usage: placeholder 'Choose...'
    def placeholder(text)
      @options[:placeholder] = text
    end

    # Usage: input_html class: 'special-input', data: { foo: 'bar' }
    def input_html(hash)
      @options[:input_html] = deep_merge_hashes(@options[:input_html] || {}, hash)
    end

    # Usage: wrapper_html class: 'custom-wrapper'
    def wrapper_html(hash)
      @options[:wrapper_html] = deep_merge_hashes(@options[:wrapper_html] || {}, hash)
    end

    # Usage: required true
    def required(value)
      @options[:required] = value
    end

    # Usage: disabled true
    def disabled(value)
      @options[:disabled] = value
    end

    # Usage: collection ['Option 1', 'Option 2']
    def collection(value)
      @options[:collection] = value
    end

    # Usage: include_blank 'Select one...'
    def include_blank(value)
      @options[:include_blank] = value
    end

    # Catch-all method for any other options
    # Allows calling arbitrary option methods like `custom_option 'value'`
    def method_missing(name, *args, &block)
      if args.size == 1 && !block
        @options[name] = args.first
      else
        super
      end
    end

    def respond_to_missing?(_name, _include_private = false)
      true
    end

    # Merge everything and return the options hash
    def to_options
      opts = @options.dup

      # Build ajax options if any ajax-related methods were called
      if @ajax_resource.present? || @ajax_params.present? || @ajax_extra.any?
        ajax = (opts[:ajax] || {}).dup
        ajax[:resource] = @ajax_resource if @ajax_resource
        ajax[:params] = @ajax_params if @ajax_params.present?
        ajax.merge!(@ajax_extra) if @ajax_extra.any?
        opts[:ajax] = ajax
      end

      opts
    end

    private

    def deep_merge_hashes(a, b)
      a.merge(b) do |_key, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          deep_merge_hashes(old_val, new_val)
        else
          new_val
        end
      end
    end
  end
end
