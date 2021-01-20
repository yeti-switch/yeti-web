# frozen_string_literal: true

module ClickhouseDictionary
  class Node < Base
    model_class ::Node

    attributes :id,
               :name,
               :pop_id
  end
end
