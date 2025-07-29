# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../app/jobs/jobs/partition_removing'

RSpec.describe Jobs::PartitionRemoving do
  let(:job) { described_class.new(double) }

  describe '#execute_cmd' do
    subject { job.send(:execute_cmd, command) }

    context 'when command is successful' do
      let(:command) { "echo 'hello world'" }

      it 'returns success status' do
        status, stdout, stderr = subject
        expect(status).to be_success
        expect(stdout).to eq "hello world\n"
        expect(stderr).to be_blank
      end
    end

    context 'when command fails' do
      let(:command) { 'command_that_does_not_exist' }

      it 'returns error status' do
        status, stdout, stderr = subject
        expect(status).not_to be_success
        expect(stdout).to be_blank
        expect(stderr).to include('command not found')
      end
    end

    context 'when command writes to stderr' do
      let(:command) { "echo 'error message' >&2" }

      it 'returns success status and stderr output' do
        status, stdout, stderr = subject
        expect(status).to be_success
        expect(stdout).to be_blank
        expect(stderr).to eq "error message\n"
      end
    end

    context 'when command writes a lot of data to stdout and stderr' do
      let(:command) do
        <<~SHELL
          ruby -e '
            STDOUT.write("o" * 1_000_000)
            STDERR.write("e" * 100_000)
          '
        SHELL
      end

      it 'reads all data without deadlocking' do
        status, stdout, stderr = subject
        expect(status).to be_success
        expect(stdout.size).to eq 1_000_000
        expect(stderr.size).to eq 100_000
      end
    end
  end
end
