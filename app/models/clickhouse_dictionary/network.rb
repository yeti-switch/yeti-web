# frozen_string_literal: true

module ClickhouseDictionary
  class Network < Base
    model_class ::System::Network

    attributes :id,
               :name
  end
end
