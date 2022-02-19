# frozen_string_literal: true

module Yeti
  class CdrsFilter
    Error = Class.new(StandardError)

    include Enumerable

    EQ_FILTERABLE = %i[
      dst_country_id
      dst_network_id
      vendor_id
      customer_id
      customer_acc_id
      vendor_acc_id
      orig_gw_id
      term_gw_id
      orig_call_id
      term_call_id
      duration
    ].freeze

    STARTS_WITH_FILTERABLE = %i[dst_prefix_routing src_prefix_routing].freeze
    GT_FILTERABLE = [:duration].freeze
    LT_FILTERABLE = [:duration].freeze
    CDR_FIELDS = [EQ_FILTERABLE + STARTS_WITH_FILTERABLE + GT_FILTERABLE + LT_FILTERABLE].uniq.freeze

    attr_accessor :params

    def initialize(nodes, params = {})
      @params = format_params(params)
      @nodes = nodes_scope(nodes)
    end

    def search(options = {})
      results = raw_cdrs(options)
      filter = generate_filter
      filter.call(results)
    end

    def raw_cdrs(options = {})
      NodeParallelRpc.call(nodes: @nodes.to_a) do |node|
        Rails.logger.info { "request to node #{node.id}" }
        calls = node.calls(options)
        Rails.logger.info { " loading  #{calls.count} active calls" }
        calls
      end
    rescue StandardError => e
      # Here we capture error from thread created by Parallel and raise new one,
      # because original exception will not have useful information, like where it were called.
      CaptureError.log_error(e)
      raise Error, "Caught #{e.class} #{e.message}"
    end

    def generate_filter
      filter = ArrayFilter.new

      EQ_FILTERABLE.each do |k|
        %i[eq equals].each do |suff|
          filter.add_filter { |cdr| cdr[:"#{k}"].to_i == search_param(k, suff).to_i } if searchable?(k, suff)
        end
      end
      STARTS_WITH_FILTERABLE.each do |k|
        filter.add_filter { |cdr| cdr[:"#{k}"].to_s.start_with? search_param(k, :starts_with) } if searchable?(k, :starts_with)
      end
      LT_FILTERABLE.each do |k|
        %i[lt less_than].each do |suff|
          filter.add_filter { |cdr| cdr[:"#{k}"].to_i < search_param(k, suff).to_i } if searchable?(k, suff)
        end
      end

      GT_FILTERABLE.each do |k|
        %i[gt greater_than].each do |suff|
          filter.add_filter { |cdr| cdr[:"#{k}"].to_i > search_param(k, suff).to_i } if searchable?(k, suff)
        end
      end

      filter
    end

    def nodes_scope(nodes)
      node_id = @params.delete(:node_id_eq)
      nodes = nodes.where(id: node_id) if node_id.present?
      nodes
    end

    def search_param(key, predicate)
      @params.fetch(:"#{key}_#{predicate}")
    end

    def searchable?(key, predicate)
      @params.key?(:"#{key}_#{predicate}")
    end

    def format_params(params)
      params = params.is_a?(Hash) ? params.dup.delete_if { |_, value| value.blank? } : {}
      params.symbolize_keys
    end
  end
end
