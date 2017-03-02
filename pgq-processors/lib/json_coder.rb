require 'json'

module JsonCoder
  VERSION = '0.1'

  class << self
    def dump(obj)
      JSON.dump obj
    end
    alias :encode :dump

    def load(str)
      JSON.parse str
    end
    alias :decode :load
  end

end