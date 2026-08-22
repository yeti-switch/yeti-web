# frozen_string_literal: true

require 'delayed_job/log_job_tags'

RSpec.describe Delayed::LogJobTagsPlugin do
  # A fresh lifecycle instead of Delayed::Worker.lifecycle, so that the callbacks of the
  # plugin are not registered in the global one for the rest of the suite.
  let(:lifecycle) { Delayed::Lifecycle.new }
  let(:worker) { instance_double(Delayed::Worker) }
  let(:job) { instance_double(Delayed::Backend::ActiveRecord::Job, id: 84_213, payload_object:) }
  let(:payload_object) { Importing::ImportingDelayedJob.new('Importing::ImportingAccount', {}) }

  before { described_class.callback_block.call(lifecycle) }

  # @return [Hash, nil] named tags of the records the job would log.
  def named_tags_while_performing
    tags = nil
    lifecycle.run_callbacks(:perform, worker, job) { tags = SemanticLogger.named_tags }
    tags
  end

  it 'tags every record logged while the job runs with the name of the job' do
    expect(named_tags_while_performing).to include(job: 'Importing::ImportingDelayedJob')
  end

  it 'tags with the delayed_jobs row, the id of the Background Tasks page' do
    expect(named_tags_while_performing).to include(dj_id: 84_213)
  end

  it 'adds no job_id: a job that is not an ActiveJob has none' do
    expect(named_tags_while_performing).not_to include(:job_id)
  end

  it 'adds no tag outside of the job' do
    named_tags_while_performing
    expect(SemanticLogger.named_tags).to be_blank
  end

  context 'when the job is an ActiveJob' do
    let(:payload_object) do
      ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper.new(
        'job_class' => 'Worker::RemoveOldRecordsJob',
        'job_id' => '07255285-cb04-43c4-8533-5fa8d3cc841f',
        'queue_name' => 'default'
      )
    end

    it 'tags with the wrapped job class, as the Background Tasks page shows it' do
      expect(named_tags_while_performing).to include(job: 'Worker::RemoveOldRecordsJob')
    end

    it 'tags with the id ActiveJob assigned, so that every attempt of the job correlates' do
      expect(named_tags_while_performing).to include(job_id: '07255285-cb04-43c4-8533-5fa8d3cc841f')
    end
  end

  context 'when the handler of the job does not deserialize' do
    let(:job) { instance_double(Delayed::Backend::ActiveRecord::Job, id: 84_213) }

    before { allow(job).to receive(:payload_object).and_raise(Delayed::DeserializationError) }

    it 'runs the job without the tags of the payload, instead of killing the worker' do
      expect(named_tags_while_performing).to eq(dj_id: 84_213)
    end
  end
end
