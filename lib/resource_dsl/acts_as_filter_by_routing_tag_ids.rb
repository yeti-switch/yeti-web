# frozen_string_literal: true

module ResourceDSL
  module ActsAsFilterByRoutingTagIds
    def acts_as_filter_by_routing_tag_ids(routing_tag_ids_covers: true, routing_tag_ids_count: false)
      # tom-select-clear: single clear-all button, no per-chip remove_button
      # (the latter races option clicks on the full-width filter control).
      if routing_tag_ids_covers
        filter :routing_tag_ids_covers, as: :select,
                                        collection: -> { Routing::RoutingTag.pluck(:name, :id) },
                                        input_html: { class: 'tom-select tom-select-clear', multiple: true }
      end

      filter :routing_tag_ids_array_contains, label: 'Routing Tag IDs Contains', as: :select,
                                              collection: -> { Routing::RoutingTag.pluck(:name, :id) },
                                              input_html: { class: 'tom-select tom-select-clear', multiple: true }

      filter :tagged, as: :select, collection: [['Yes', true], ['No', false]], input_html: { class: 'tom-select' }

      filter :routing_tag_ids_count, as: :numeric, filters: [:equals] if routing_tag_ids_count
    end
  end
end
