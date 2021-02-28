# frozen_string_literal: true

module Yeti
  module SipOptionsProberReloader
    extend ActiveSupport::Concern
    included do
      before_save :reload_sip_options_probers
      before_update :reload_old_sip_options_probers
      before_destroy :reload_sip_options_probers
    end

    private

    def reload_sip_options_probers
      Event.reload_sip_options_probers(node_id: node_id, pop_id: pop_id)
    end

    def reload_old_sip_options_probers
      return if !attribute_changed?(:node_id) && !attribute_changed?(:pop_id)

      old_node_id = attribute_changed?(:node_id) ? attribute_was(:node_id) : nil
      old_pop_id = attribute_changed?(:pop_id) ? attribute_was(:pop_id) : nil
      Event.reload_sip_options_probers(node_id: old_node_id, pop_id: old_pop_id)
    end
  end
end
