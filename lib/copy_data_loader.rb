# frozen_string_literal: true

module CopyDataLoader
  def self.load(model_class:, data:, columns:)
    raw = model_class.connection.raw_connection
    enc = PG::TextEncoder::CopyRow.new
    raw.copy_data("COPY #{model_class.table_name} (#{columns.join(',')}) FROM STDIN", enc) do
      data.each { |r| raw.put_copy_data(columns.map { |c| r[c] }) }
    end
  end
end
