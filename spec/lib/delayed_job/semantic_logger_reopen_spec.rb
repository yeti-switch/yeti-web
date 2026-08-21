# frozen_string_literal: true

require 'delayed_job/semantic_logger_reopen'

RSpec.describe Delayed::SemanticLoggerReopen do
  describe 'Delayed::Worker.after_fork' do
    # Delayed::Worker.after_fork reopens the files that before_fork collected. before_fork
    # is not called here: it also clears every ActiveRecord connection, including the one
    # the transactional fixtures of the example are open on.
    before do
      allow(Delayed::Worker.backend).to receive(:after_fork)
      Delayed::Worker.instance_variable_set(:@files_to_reopen, [])
    end

    after { Delayed::Worker.instance_variable_set(:@files_to_reopen, nil) }

    it 'reopens SemanticLogger, so that the forked worker has an alive appender thread' do
      expect(SemanticLogger).to receive(:reopen)

      Delayed::Worker.after_fork
    end
  end
end
