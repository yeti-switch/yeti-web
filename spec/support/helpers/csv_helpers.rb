# frozen_string_literal: true

module CsvHelpers
  def create_csv_file(headers, rows)
    path = Rails.root.join("tmp/test-file-#{SecureRandom.uuid}.csv")
    CSV.open(path, 'w') do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end
    Rack::Test::UploadedFile.new(path, 'text/csv', false)
  end

  def parse_csv_text(text)
    CSV.parse(
      text,
      headers: true,
      header_converters: ->(header) { convert_csv_header(header) },
      nil_value: nil
    ).map(&:to_hash)
  end

  def convert_csv_header(header)
    header.to_s.encode('utf-8', replace: '').parameterize.underscore.to_sym
  end
end

RSpec.configure do |config|
  config.include CsvHelpers
end
