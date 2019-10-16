# frozen_string_literal: true

module ClickhouseDictionary
  class Country < Base
    model_class ::System::Country

    attributes :id,
               :name,
               :iso2
  end
end
