module Yeti
  class OutgoingRegistrations
    def initialize(nodes, params = {})
      @params = clean_search_params(params).with_indifferent_access
      set_nodes(nodes)
    end

    def search
      raw_registrations
    end

    def raw_registrations
      raw = Parallel.map(@nodes.to_a, in_threads: @nodes.count) do |node|
        Rails.logger.info { "request to node #{node.id}" }
        registrations = node.registrations
        Rails.logger.info { " loading  #{registrations.count} registrations" }
        registrations
      end
      raw.flatten
    end

    def set_nodes(nodes)
      if @params[:node_id_eq].present?
        @nodes = nodes.where(id: @params.delete(:node_id_eq))
      else
        @nodes = nodes
      end
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