# frozen_string_literal: true

module Yeti
  module RegistrationReloader
    extend ActiveSupport::Concern
    included do
      after_update do
        if pop_id_changed? || node_id_changed?
          Event.reload_registrations(pop_id: pop_id_was, node_id: node_id_was, id: id)
        end
      end

      after_save do
        Event.reload_registrations(pop_id: pop_id, node_id: node_id, id: id)
      end

      after_destroy do
        Event.reload_registrations(pop_id: pop_id_was, node_id: node_id_was, id: id_was)
      end
    end
  end
end
