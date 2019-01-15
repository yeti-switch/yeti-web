# frozen_string_literal: true

module Yeti
  class CdrsFilter
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
      @params = clean_search_params(params).with_indifferent_access
      set_nodes(nodes)
    end

    def search(options = {})
      results = raw_cdrs(options)
      lambda_filter = search_lambda
      results.select { |cdr| lambda_filter.call(cdr) }
    end

    def raw_cdrs(options = {})
      raw = Parallel.map(@nodes.to_a, in_threads: @nodes.count) do |node|
        Rails.logger.info { "request to node #{node.id}" }

        calls = node.calls(options)
        Rails.logger.info { " loading  #{calls.count} active calls" }
        calls
      end
      raw.flatten
    end

    def search_lambda
      parts = []
      EQ_FILTERABLE.each do |k|
        %i[eq equals].each do |suff|
          parts << " cdr['#{k}'].to_i == #{search_param(k, suff).to_i}" if searchable?(k, suff)
        end
      end
      STARTS_WITH_FILTERABLE.each do |k|
        parts << " cdr['#{k}'].to_s.starts_with?('#{search_param(k, :starts_with)}' ) " if searchable?(k, :starts_with)
      end
      LT_FILTERABLE.each do |k|
        %i[lt less_than].each do |suff|
          parts << " cdr['#{k}'].to_i < #{search_param(k, suff).to_i}  " if searchable?(k, suff)
        end
      end

      GT_FILTERABLE.each do |k|
        %i[gt greater_than].each do |suff|
          parts << " cdr['#{k}'].to_i > #{search_param(k, suff).to_i} " if searchable?(k, suff)
        end
      end

      source = if parts.any?
                 'lambda { |cdr|  ' + parts.join(' && ') + ' }'
               else
                 'lambda { |cdr| cdr }'
               end

      Rails.logger.info { 'lambda ---- > ' }
      Rails.logger.info { source }
      eval source
    end

    def set_nodes(nodes)
      @nodes = if @params[:node_id_eq].present?
                 nodes.where(id: @params.delete(:node_id_eq))
               else
                 nodes
               end
    end

    def search_param(key, predicate)
      @params["#{key}_#{predicate}"]
    end

    def searchable?(key, predicate)
      @params["#{key}_#{predicate}"].present?
    end

    def clean_search_params(params)
      if params.is_a? Hash
        params.dup.delete_if { |_, value| value.blank? }
      else
        {}
      end
    end
  end
end
