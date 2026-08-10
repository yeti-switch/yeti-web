# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/hook_config')

RSpec.describe HookConfig, '.configured?' do
  subject { described_class.configured?(:partition_remove_hook) }

  # Reading through public_send keeps this stubbable: config/yeti_web.yml ships
  # partition_remove_hook commented out, so YetiConfig does not respond to it.
  def stub_hook(value)
    allow(YetiConfig).to receive(:public_send).and_call_original
    allow(YetiConfig).to receive(:public_send).with(:partition_remove_hook).and_return(value)
  end

  it 'is false when the hook is not configured' do
    expect(subject).to be(false)
  end

  it 'is false when the hook is configured blank' do
    stub_hook('  ')
    expect(subject).to be(false)
  end

  it 'is true when a hook command is configured' do
    stub_hook('/usr/local/bin/partition-removed')
    expect(subject).to be(true)
  end

  # The exporter must keep exporting every other process's metrics even when
  # config/yeti_web.yml could not be loaded at all (see YetiConfigLoader).
  it 'is false, without raising, when YetiConfig is unusable' do
    allow(YetiConfig).to receive(:public_send).and_raise(NameError, 'uninitialized constant YetiConfig')
    expect { subject }.to output(/HookConfig: NameError/).to_stderr
    expect(subject).to be(false)
  end
end
