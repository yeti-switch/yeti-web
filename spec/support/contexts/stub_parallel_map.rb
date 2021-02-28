# frozen_string_literal: true

# For some reason rspec failures inside threads created by Parallel.map
# make test run hangs for infinite time.
# Reproduced on Node api calls.
# To avoid this we can make Parallel.map run as ordinary
RSpec.shared_context :stub_parallel_map do
  before do
    allow(Parallel).to receive(:map).and_wrap_original do |_meth, *args, &block|
      expect(args.size).to eq(2)
      expect(args.second).to match(in_threads: be > 0)
      args.first.map { |item| block.call(item) }
    end
  end
end
