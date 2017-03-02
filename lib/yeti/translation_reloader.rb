module Yeti
  module TranslationReloader
    extend ActiveSupport::Concern
    included do

      before_save do
        Event.reload_translations
      end

      before_destroy do
        Event.reload_translations
      end
    end
  end
end
