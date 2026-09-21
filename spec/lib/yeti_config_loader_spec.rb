# frozen_string_literal: true

require_relative Rails.root.join('lib/yeti_config_loader')

RSpec.describe YetiConfigLoader, '.call' do
  it 'does nothing when YetiConfig is already loaded' do
    expect { described_class.call('/nonexistent/yeti_web.yml') }.not_to raise_error
  end

  context 'when YetiConfig has not been loaded yet' do
    before { hide_const('YetiConfig') }

    it 'raises rather than starting without a config' do
      expect { described_class.call('/nonexistent/yeti_web.yml') }
        .to raise_error(YetiConfigLoader::Error, %r{config file not found: /nonexistent/yeti_web.yml})
    end

    it 'raises before touching the global Config setup' do
      expect(Config).not_to receive(:setup)
      expect { described_class.call('/nonexistent/yeti_web.yml') }.to raise_error(YetiConfigLoader::Error)
    end

    it 'reports an invalid config as its own error, not the gem class' do
      allow(Config).to receive(:load_and_set_settings)
        .and_raise(Config::Validation::Error, 'site_title: must be a string')

      expect { described_class.call }
        .to raise_error(YetiConfigLoader::Error, /invalid config .*yeti_web\.yml: site_title: must be a string/)
    end
  end
end
