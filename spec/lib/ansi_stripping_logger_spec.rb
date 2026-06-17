# frozen_string_literal: true

require 'logger'
require 'stringio'

RSpec.describe AnsiStrippingLogger do
  let(:io) { StringIO.new }
  let(:inner) { Logger.new(io) }

  subject(:logger) { described_class.new(inner) }

  it 'strips ANSI escapes (incl. the click_house orphan color code) from string messages' do
    logger.info("\e[1m[35mSQL (Total: 1MS, CH: 1MS) SELECT 1 FROM cdrs FORMAT JSON;\e[0m")
    logger.info("\e[1m[36mRead: 10 rows, 1KiB. Written: 0 rows, 0B\e[0m")

    expect(io.string).to include('SQL (Total: 1MS, CH: 1MS) SELECT 1 FROM cdrs FORMAT JSON;')
    expect(io.string).to include('Read: 10 rows, 1KiB. Written: 0 rows, 0B')
    expect(io.string).not_to include("\e")     # no ESC bytes (the journald "blob" trigger)
    expect(io.string).not_to match(/\[3\dm/)   # no orphaned color codes either
  end

  it 'passes non-string payloads through untouched' do
    spy = instance_double(Logger, info: nil)
    described_class.new(spy).info({ event: 'x' })
    expect(spy).to have_received(:info).with({ event: 'x' })
  end

  it 'forwards predicate and other methods to the wrapped logger' do
    expect(logger.debug?).to eq(inner.debug?)
    expect(logger.level).to eq(inner.level)
  end
end
