# frozen_string_literal: true

RSpec.describe PrometheusConfig do
  shared_examples :a_hook_reader do |method, config_key|
    subject { described_class.public_send(method) }

    it 'is false when the hook is not configured' do
      expect(subject).to be(false)
    end

    it 'is false when the hook is configured blank' do
      allow(YetiConfig).to receive(config_key).and_return('  ')
      expect(subject).to be(false)
    end

    it 'is true when a hook command is configured' do
      allow(YetiConfig).to receive(config_key).and_return('/usr/local/bin/hook')
      expect(subject).to be(true)
    end
  end

  describe '.partition_remove_hook_configured?' do
    it_behaves_like :a_hook_reader, :partition_remove_hook_configured?, :partition_remove_hook
  end

  describe '.cdr_compaction_hook_configured?' do
    it_behaves_like :a_hook_reader, :cdr_compaction_hook_configured?, :cdr_compaction_hook
  end
end
