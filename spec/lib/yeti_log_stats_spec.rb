# frozen_string_literal: true

require 'yeti_log_stats'

RSpec.describe YetiLogStats, '.metrics' do
  subject { described_class.metrics(processor: 'cdr_billing') }

  let(:stats) do
    {
      queue_size: 3, capped: true, max_queue_size: 10_000, thread_active: true,
      processed: 42, dropped: 0, appenders: appenders
    }
  end
  let(:appenders) do
    [
      { name: 'SemanticLogger::Appender::IO', async: false },
      {
        name: 'YetiElasticsearchAppender', async: true, thread_active: true,
        queue_size: 7, capped: true, max_queue_size: 10_000, processed: 100, dropped: 5
      }
    ]
  end

  before do
    allow(SemanticLogger).to receive(:stats).and_return(stats)
    YetiLogComponent.current = 'cdr_processor'
  end

  after { YetiLogComponent.reset! }

  it 'reports the queue of SemanticLogger itself and of every asynchronous appender' do
    expect(subject.map { |metric| metric[:metric_labels][:queue] })
      .to eq(%w[processor YetiElasticsearchAppender])
  end

  it 'skips the appenders that write inline and have no queue' do
    expect(subject.map { |metric| metric[:metric_labels][:queue] })
      .not_to include('SemanticLogger::Appender::IO')
  end

  # The same name and the same value as the `component` field of the log records the
  # queue holds, see YetiLogFormatter, so that a series and its logs share a label.
  it 'labels every payload with the component of the process' do
    expect(subject).to all(include(metric_labels: hash_including(component: 'cdr_processor')))
  end

  it 'labels every payload with the pid, so that two puma workers stay apart' do
    expect(subject).to all(include(metric_labels: hash_including(pid: Process.pid)))
  end

  it 'keeps the labels of the caller' do
    expect(subject).to all(include(metric_labels: hash_including(processor: 'cdr_billing')))
  end

  it 'reports the queue of the appender' do
    expect(subject.last).to include(
      type: 'yeti_log', queue_size: 7, max_queue_size: 10_000,
      thread_active: 1, processed: 100, dropped: 5
    )
  end

  context 'with an unbounded queue' do
    let(:appenders) do
      [{
        name: 'YetiElasticsearchAppender', async: true, thread_active: false,
        queue_size: 900, capped: false, max_queue_size: nil, processed: 1, dropped: 0
      }]
    end

    # nil would delete the series from the gauge, leaving no way to tell an unbounded
    # queue from an appender that stopped reporting.
    it 'reports the limit as -1 and not as nil' do
      expect(subject.last).to include(max_queue_size: -1, thread_active: 0)
    end
  end
end
