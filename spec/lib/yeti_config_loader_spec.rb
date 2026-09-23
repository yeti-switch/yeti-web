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

  describe '.check_databases!' do
    before { allow(YetiConfig).to receive(:probes).and_return(OpenStruct.new(ready_require_databases: names)) }

    context 'when every required database is configured' do
      let(:names) { %w[primary cdr] }

      it 'passes' do
        expect { described_class.check_databases!(%w[primary cdr cdr_replica]) }.not_to raise_error
      end
    end

    context 'when a required database is not configured' do
      let(:names) { %w[primary cdr_repilca] }

      it 'raises naming it and the configured ones' do
        expect { described_class.check_databases!(%w[primary cdr]) }.to raise_error(
          YetiConfigLoader::Error, 'invalid config probes.ready_require_databases: unknown cdr_repilca, database.yml has primary, cdr'
        )
      end
    end

    context 'without probes config' do
      let(:names) { nil }

      it 'passes' do
        expect { described_class.check_databases!(%w[primary]) }.not_to raise_error
      end
    end

    context 'without a database.yml section for the environment' do
      let(:names) { %w[primary cdr_repilca] }

      it 'checks nothing' do
        expect { described_class.check_databases!(nil) }.not_to raise_error
        expect { described_class.check_databases!([]) }.not_to raise_error
      end
    end
  end
end
