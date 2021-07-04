# frozen_string_literal: true

# https://github.com/HornsAndHooves/lazy_object
# Lazy object wrapper.
#
# Pass a block to the initializer, which returns an instance of the target
# object. Lazy object forwards all method calls to the target. The block only
# gets called the first time a method is forwarded.
#
# Example:
#
# lazy = LazyObject.new { VeryExpensiveObject.new } # At this point the VeryExpensiveObject hasn't been initialized yet.
# lazy.get_expensive_results(foo, bar) # Initializes VeryExpensiveObject and calls 'get_expensive_results' on it, passing in foo and bar
class LazyObject < BasicObject
  def initialize(&callable)
    @__callable__ = callable
  end

  # Cached target object.
  def __target_object__
    @__target_object__ ||= @__callable__.call
  end

  # Forwards all method calls to the target object.
  def method_missing(method_name, *args, &block)
    __target_object__.send(method_name, *args, &block)
  end
end
