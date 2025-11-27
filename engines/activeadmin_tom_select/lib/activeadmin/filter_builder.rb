# frozen_string_literal: true

module ActiveAdmin
  # Helper class to create patch for index filters feature
  class FilterBuilder
    def initialize(options = {})
      @options = options.dup
      @ajax_resource = nil
      @ajax_params = {}
      @ajax_extra = {}
    end

    # Usage: ajax resource: Contractor
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

    # simple setters so DSL can call `as :string`, etc.
    def as(value)
      @options[:as] = value
    end

    def input_html(hash)
      @options[:input_html] = hash
    end

    def placeholder(text)
      @options[:placeholder] = text
    end

    # catch-all: allow calling arbitrary option methods like `label 'Customer'`
    def method_missing(name, *args, &block)
      # if user calls label 'Customer' or label: 'Customer' style
      if args.size == 1 && !block
        @options[name] = args.first
      else
        super
      end
    end

    def respond_to_missing?(_name, _include_private = false)
      true
    end

    # Merge everything and return the options hash ActiveAdmin expects
    def to_options
      opts = @options.dup

      if @ajax_resource.present? || @ajax_params.present? || @ajax_extra.any?
        opts[:as] ||= :select
        ajax = (opts[:ajax] || {}).dup
        ajax[:resource] = @ajax_resource if @ajax_resource
        ajax[:params]   = @ajax_params   if @ajax_params
        ajax.merge!(@ajax_extra) if @ajax_extra.any?
        opts[:ajax] = ajax
      else
        opts[:ajax] = false
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
