# frozen_string_literal: true

module ClickhouseDictionary
  class NetworkPrefix < Base
    model_class ::System::NetworkPrefix

    attributes :id,
               :prefix,
               :country_id,
               :network_id

    attribute :country_name, sql: 'sys.countries.name'
    attribute :network_name, sql: 'sys.networks.name'

    private

    def scoped_collection
      super.joins(:country, :network)
    end
  end
end
