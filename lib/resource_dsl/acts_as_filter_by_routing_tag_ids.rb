# frozen_string_literal: true

module ResourceDSL
  module ActsAsFilterByRoutingTagIds
    def acts_as_filter_by_routing_tag_ids(is_ids_covers: true)
      if is_ids_covers
        filter :routing_tag_ids_covers, as: :select,
                                        collection: -> { Routing::RoutingTag.pluck(:name, :id) },
                                        input_html: { class: 'chosen', multiple: true }
      end

      filter :routing_tag_ids_array_contains, label: 'Routing Tag IDs Contains', as: :select,
                                              collection: -> { Routing::RoutingTag.pluck(:name, :id) },
                                              input_html: { class: 'chosen', multiple: true }

      filter :tagged, as: :select, collection: [['Yes', true], ['No', false]]
    end
  end
end
