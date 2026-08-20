# frozen_string_literal: true

require 'delayed_job/semantic_logger_reopen'

RSpec.describe Delayed::SemanticLoggerReopen do
  describe 'Delayed::Worker.after_fork' do
    it 'reopens SemanticLogger, so that the forked worker has an alive appender thread' do
      allow(Delayed::Worker.backend).to receive(:after_fork)
      Delayed::Worker.before_fork # fills the list of files to reopen
      expect(SemanticLogger).to receive(:reopen)

      Delayed::Worker.after_fork
    end
  end
end
