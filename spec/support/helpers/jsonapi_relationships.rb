module Helpers
  module JsonapiRelationships
    def wrap_relationship(type, id)
      { data: { type: type, id: id } }
    end

    def wrap_has_many_relationship(type, ids)
      { data: ids.map {|id| { type: type, id: id}} }
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::JsonapiRelationships
end
