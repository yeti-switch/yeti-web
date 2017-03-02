if Rails.env.development?
  MAX_LOG_SIZE = 10.megabytes

  logs = File.join(Rails.root, 'log', '*.log')
  if Dir[logs].any? {|log| File.size?(log).to_i > MAX_LOG_SIZE }
    $stdout.puts "Development log files too large. Running rake log:clear"
    $stdout.puts `rake log:clear RAILS_ENV=development`
  end
end