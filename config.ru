# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'lib/yeti_log_component'
YetiLogComponent.current = 'puma'

require_relative 'config/environment'

run Rails.application
Rails.application.load_server
