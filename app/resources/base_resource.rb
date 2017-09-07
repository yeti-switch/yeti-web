class BaseResource < JSONAPI::Resource
  abstract

  def self.type(custom_type)
    self._type = custom_type
  end
end
