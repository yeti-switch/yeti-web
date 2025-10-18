# frozen_string_literal: true

module ResourceDSL
  module ActsAsFilterByRoutingTagIds
    def acts_as_filter_by_routing_tag_ids(routing_tag_ids_covers: true, routing_tag_ids_count: false)
      if routing_tag_ids_covers
        filter :routing_tag_ids_covers, as: :tom_select,
                                        collection: -> { Routing::RoutingTag.pluck(:name, :id) },
                                        multiple: true,
                                        include_hidden: false
      end

      filter :routing_tag_ids_array_contains, label: 'Routing Tag IDs Contains', as: :tom_select,
                                              collection: -> { Routing::RoutingTag.pluck(:name, :id) },
                                              multiple: true, include_hidden: false

      boolean_filter :tagged

      filter :routing_tag_ids_count, as: :numeric, filters: [:equals] if routing_tag_ids_count
    end
  end
end
