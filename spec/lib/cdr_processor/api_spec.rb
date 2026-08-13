# frozen_string_literal: true

# CdrProcessor::CdrDb has no connection of its own in specs (bin/cdr_processor
# establishes it), so these run against the primary test database. pgq_ext is
# installed in both databases and the statement under test is the same either
# way.
RSpec.describe CdrProcessor::Api do
  let(:consumer_name) { 'spec_cdr_http_bulk' }
  let(:batch_id) { 999_999 }

  def event_done?(event_id)
    CdrProcessor::CdrDb.connection.select_value(
      CdrProcessor::CdrDb.sanitize_sql_array(
        ['SELECT pgq_ext.is_event_done(?, ?, ?)', consumer_name, batch_id, event_id]
      )
    )
  end

  describe '.pgq_event_done!' do
    it 'marks the event as done' do
      expect(CdrProcessor::CdrDb.pgq_event_done!(consumer_name, batch_id, 1)).to be(true)
      expect(event_done?(1)).to be(true)
    end

    it 'is false when the event was already done' do
      CdrProcessor::CdrDb.pgq_event_done!(consumer_name, batch_id, 1)

      expect(CdrProcessor::CdrDb.pgq_event_done!(consumer_name, batch_id, 1)).to be(false)
    end
  end

  describe '.pgq_event_done?' do
    it 'is false for an event that was not marked as done' do
      expect(CdrProcessor::CdrDb.pgq_event_done?(consumer_name, batch_id, 1)).to be(false)
    end

    it 'is true for an event marked as done one by one' do
      CdrProcessor::CdrDb.pgq_event_done!(consumer_name, batch_id, 1)

      expect(CdrProcessor::CdrDb.pgq_event_done?(consumer_name, batch_id, 1)).to be(true)
    end

    it 'is true for an event marked as done in bulk' do
      CdrProcessor::CdrDb.pgq_events_done!(consumer_name, batch_id, [1, 2])

      expect(CdrProcessor::CdrDb.pgq_event_done?(consumer_name, batch_id, 2)).to be(true)
    end
  end

  describe '.pgq_events_done!' do
    it 'marks every given event of the batch as done' do
      CdrProcessor::CdrDb.pgq_events_done!(consumer_name, batch_id, [3, 1, 2])

      expect([1, 2, 3].map { |event_id| event_done?(event_id) }).to eq([true, true, true])
      expect(event_done?(4)).to be(false)
    end

    it 'does nothing when the event list is empty' do
      CdrProcessor::CdrDb.pgq_events_done!(consumer_name, batch_id, [])

      expect(event_done?(1)).to be(false)
    end
  end
end
