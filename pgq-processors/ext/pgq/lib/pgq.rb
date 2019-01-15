# frozen_string_literal: true

require 'active_support'
require 'active_record'

module Pgq
end

Dir[File.dirname(__FILE__) + '/pgq/*.rb'].each { |f| require f }

ActiveRecord::Base.extend(Pgq::Api) if defined?(ActiveRecord::Base)
