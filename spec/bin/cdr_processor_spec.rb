# frozen_string_literal: true

require 'open3'

# bin/cdr_processor runs the worker WITHOUT booting Rails, so it never sets up
# autoloading: every constant it reaches (e.g. HttpxProxy, which lives in
# app/lib) must be required explicitly by the script. An in-Rails spec cannot
# catch a missing require because Zeitwerk resolves the constant for it.
#
# `--check` boots the real require chain, instantiates the processor and forces
# its lazily-referenced dependencies to resolve, then exits 0 without touching
# AMQP or the processing loop. Running it here guards against a lib/ -> app/lib
# (or any autoloaded path) coupling slipping into the standalone worker.
RSpec.describe 'bin/cdr_processor --check' do
  root = File.expand_path('../..', __dir__)
  bin = File.join(root, 'bin/cdr_processor')
  config = File.join(root, 'spec/fixtures/cdr_processors_check.yml')

  # Both HTTP processors resolve HttpxProxy via CdrHttpBase#proxy; the other
  # processors are excluded because their constructors open real connections
  # (cdr_amqp) or otherwise require external services.
  %w[cdr_http cdr_http_batch].each do |processor|
    it "boots the #{processor} processor with all constants resolved" do
      out, status = Open3.capture2e(RbConfig.ruby, bin, processor, config, '--check', chdir: root)

      expect(status.exitstatus).to eq(0), "expected clean boot, got:\n#{out}"
      expect(out).to include('check passed')
    end
  end
end
