module Yeti
  module RegistrationReloader
    extend ActiveSupport::Concern
    included do

      after_update do
        if (pop_id_changed? || node_id_changed?)
          Event.reload_registrations({pop_id: self.pop_id_was, node_id: self.node_id_was, id: self.id})
        end
      end

      after_save do
        Event.reload_registrations({pop_id: self.pop_id, node_id: self.node_id, id: self.id})
      end

      after_destroy do
        Event.reload_registrations({pop_id: self.pop_id_was, node_id: self.node_id_was, id: self.id_was})
      end
    end
  end
end
