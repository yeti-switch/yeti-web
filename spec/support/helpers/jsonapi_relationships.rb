module Helpers
  module JsonapiRelationships
    def wrap_relationship(type, id)
      { data: { type: type, id: id } }
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::JsonapiRelationships
end
