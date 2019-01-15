# frozen_string_literal: true

module Yeti
  module CodecReloader
    extend ActiveSupport::Concern
    included do
      before_save do
        Event.reload_codec_groups
      end

      before_destroy do
        Event.reload_codec_groups
      end
    end
  end
end
