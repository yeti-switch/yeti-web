module Helpers
  module Serialize
    def serialize(resource_class, object, context=nil)
      JSONAPI::ResourceSerializer.new(resource_class).serialize_to_hash(resource_class.new(object, context))
    end

    def serialize_array(resource_class, array, context=nil)
      resources = array.inject([]) do |acc, e|
        acc << resource_class.new(e, context)
        acc
      end
      JSONAPI::ResourceSerializer.new(resource_class).serialize_to_hash(resources)
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::Serialize
end
