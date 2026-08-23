# frozen_string_literal: true

require 'delayed_job/job_name'

RSpec.describe Delayed::JobName do
  describe '.call' do
    subject { described_class.call(payload_object) }

    context 'when the job is an ActiveJob' do
      let(:payload_object) do
        ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper.new(
          'job_class' => 'Worker::RemoveOldRecordsJob', 'job_id' => 'a-b-c', 'queue_name' => 'default'
        )
      end

      it 'is the wrapped job class and not the wrapper' do
        expect(subject).to eq('Worker::RemoveOldRecordsJob')
      end
    end

    context 'when the job is a plain payload object' do
      let(:payload_object) { Importing::ImportingDelayedJob.new('Importing::ImportingAccount', {}) }

      it { is_expected.to eq('Importing::ImportingDelayedJob') }
    end
  end

  describe '.from_handler' do
    subject { described_class.from_handler(handler) }

    let(:handler) { "--- !ruby/object:Worker::RemovedJob\njob_data:\n  job_class: Worker::RemovedJob\n" }

    it 'parses the class out of the yaml of a job that does not deserialize' do
      expect(subject).to eq('Worker::RemovedJob')
    end

    context 'when the yaml holds no class name' do
      let(:handler) { '--- {}' }

      it { is_expected.to be_nil }
    end
  end
end
