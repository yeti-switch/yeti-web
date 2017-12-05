module Yeti
  class OutgoingRegistrations

    attr_reader :errors

    def initialize(nodes, params = {})
      @params = clean_search_params(params).with_indifferent_access
      @errors = []
      set_nodes(nodes)
    end

    def search(options = {})
      raw_registrations(options)
    end

    def raw_registrations(options = {})
      raw = Parallel.map(@nodes.to_a, in_threads: @nodes.count) do |node|
        Rails.logger.info { "request to node #{node.id}" }
        registrations = []
        begin
          registrations = node.registrations
        rescue StandardError => e
          raise e unless options[:empty_on_error]
          @errors << e.message
        end
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
