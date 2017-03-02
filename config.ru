# This file is used by Rack-based servers to start the application.
require 'unicorn/worker_killer'
use Unicorn::WorkerKiller::MaxRequests, 700, 1000

require ::File.expand_path('../config/environment',  __FILE__)
run Yeti::Application
