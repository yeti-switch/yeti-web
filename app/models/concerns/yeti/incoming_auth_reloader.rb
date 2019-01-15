# frozen_string_literal: true

module Yeti
  module IncomingAuthReloader
    extend ActiveSupport::Concern
    included do
      before_save do
        Event.reload_incoming_auth
      end

      before_destroy do
        Event.reload_incoming_auth
      end
    end
  end
end
