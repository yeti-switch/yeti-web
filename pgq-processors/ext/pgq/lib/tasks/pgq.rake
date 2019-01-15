# frozen_string_literal: true

namespace :pgq do
  desc 'Start worker'
  task :worker do
    w = Pgq::Worker.new(sleep_time: 0.5)
    w.run
  end
end
