# frozen_string_literal: true

desc 'Start PGQ CDR processor'
task cdr_processor: :environment do
  CdrProcessor::Runner.new(
    processor_name: ENV.fetch('processor'),
    config_file: ENV['config_file']
  ).start
end
