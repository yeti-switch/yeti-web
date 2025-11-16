# frozen_string_literal: true

# Custom on demand seeds.
# Usage:
# * add file to db/custom_seeds/example.rb
# * run `rake custom_seeds[example]`
#
task custom_seeds: :environment do |_t, args|
  args = args.to_a
  raise ArgumentError, 'provide at least one file like this: `rake custom_seeds[cdrs]`' if args.empty?

  Rails.logger.info "Running custom_seeds #{args.join(', ')}"
  files = args.map { |name| Rails.root.join("db/custom_seeds/#{name}.rb") }
  missing_files = files.reject { |filepath| File.exist?(filepath) }
  raise ArgumentError, "missing files: #{missing_files.join(', ')}" if missing_files.any?

  files.each do |filepath|
    load(filepath)
  end
end
