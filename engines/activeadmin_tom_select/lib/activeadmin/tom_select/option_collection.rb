# frozen_string_literal: true

module ActiveAdmin
  module TomSelect
    # @api private
    class OptionCollection
      def initialize(name, options)
        @name = name
        @scope = extract_scope_option(options)
        @display_text = extract_display_text_option(options)
        @filter = extract_filter_option(options)
        @per_page = options.fetch(:per_page, 10)
        @additional_payload = options.fetch(:additional_payload, {})
      end

      def scope(template, params)
        case @scope
        when Proc
          if @scope.arity.zero?
            template.instance_exec(&@scope)
          else
            template.instance_exec(params, &@scope)
          end
        else
          @scope
        end
      end

      def display_text(record)
        @display_text.call(record)
      end

      def collection_action_name
        "#{@name}_options"
      end

      def as_json(template, params)
        records, more = fetch_records(template, params)

        results = records.map do |record|
          {
            id: record.id,
            text: display_text(record)
          }.merge(hash_of_additional_payload(record) || {})
        end

        # Include current page in pagination info (1-based)
        current_page = params[:page].to_i
        current_page = 1 if current_page < 1

        { results: results, pagination: { more: more, current: current_page } }
      end

      private

      attr_reader :per_page

      def fetch_records(template, params)
        paginate(filter(scope(template, params), params[:term]),
                 params[:page])
      end

      def filter(scope, term)
        term ? @filter.call(term, scope) : scope
      end

      def paginate(scope, page_index)
        # Use 1-based pagination (page 1 is the first page)
        # Default to page 1 if not specified or invalid
        page_index = page_index.to_i
        page_index = 1 if page_index < 1

        # Calculate offset for 1-based pagination
        offset = (page_index - 1) * per_page
        records = scope.limit(per_page + 1).offset(offset).to_a

        [
          records.slice(0, per_page),
          records.size > per_page
        ]
      end

      def extract_scope_option(options)
        options.fetch(:scope) do
          raise('Missing option: scope. ' \
                'Pass the collection of items to render options for.')
        end
      end

      def extract_display_text_option(options)
        options.fetch(:display_text) do
          text_attribute = options.fetch(:text_attribute) do
            raise('Missing option: text_attribute. ' \
                  'Pass the name of the attribute to use for display text.')
          end

          ->(record) { record.send(text_attribute) }
        end
      end

      def extract_filter_option(options)
        options.fetch(:filter) do
          text_attribute = options.fetch(:text_attribute) do
            raise('Missing option: text_attribute. ' \
                  'Pass the name of the attribute to use for filtering.')
          end

          ->(term, scope) { scope.ransack("#{text_attribute}_cont" => term).result }
        end
      end

      def build_additional_payload(record)
        case @additional_payload
        when Proc
          @additional_payload.call(record).to_h
        else
          {}
        end
      end

      def hash_of_additional_payload(record)
        return nil if @additional_payload.nil? && @additional_payload.empty?

        build_additional_payload(record)
      end
    end
  end
end
