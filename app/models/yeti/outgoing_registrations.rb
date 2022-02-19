# frozen_string_literal: true

module Yeti
  class OutgoingRegistrations
    Error = Class.new(StandardError)
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
      NodeParallelRpc.call(nodes: @nodes.to_a) do |node|
        retrieve_registrations(node, options)
      end
    rescue StandardError => e
      # Here we capture error from thread created by Parallel and raise new one,
      # because original exception will not have useful information, like where it were called.
      CaptureError.log_error(e)
      raise Error, "Caught #{e.class} #{e.message}"
    end

    def set_nodes(nodes)
      @nodes = if @params[:node_id_eq].present?
                 nodes.where(id: @params.delete(:node_id_eq))
               else
                 nodes
               end
    end

    def clean_search_params(params)
      if params.is_a? Hash
        params.dup.delete_if { |_, value| value.blank? }
      else
        {}
      end
    end

    def retrieve_registrations(node, options)
      Rails.logger.info { "request to node #{node.id}" }
      registrations = []
      begin
        registrations = node.registrations
      rescue StandardError => e
        raise e unless options[:empty_on_error]

        Rails.logger.error { "<#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
        CaptureError.capture(e, extra: { model_class: self.class.name, node_id: node&.id })
        @errors << e.message
      end
      Rails.logger.info { " loading  #{registrations.count} registrations" }
      registrations
    end
  end
end
