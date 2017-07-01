module Yeti
  module NetworkDetector
    extend ActiveSupport::Concern


    EMPTY_NETWORK_HINT = 'Unknown network'

    included do

      belongs_to :network_prefix, class_name: 'System::NetworkPrefix'
      has_one :country, through: :network_prefix
      has_one :network, through: :network_prefix

      before_save do
        detect_network_prefix!
      end
    end

    def detect_network_prefix!
      self.network_prefix = System::NetworkPrefix.longest_match(self.prefix)
    end

    def network_details_hint
      self.network_prefix.try!(:hint) || EMPTY_NETWORK_HINT
    end

  end
end