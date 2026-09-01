# frozen_string_literal: true

require_relative Rails.root.join('lib/yeti_config_loader')

RSpec.describe YetiConfigLoader, '.call' do
  it 'does nothing when YetiConfig is already loaded' do
    expect { described_class.call('/nonexistent/yeti_web.yml') }.not_to raise_error
  end

  # Config.load_and_set_settings defines the settings before the outdated keys can be
  # rejected, so a caller that rescues the error - the config/application.rb preload of
  # YetiLogSetup.preloaded_stdout_level - leaves a loaded YetiConfig behind. The next
  # caller must still be told, or Rails boots with the logging silently disabled.
  it 'still reports an outdated config that a previous caller loaded and rescued' do
    stub_const('YetiConfig', OpenStruct.new(logs: {}))

    expect { described_class.call('/some/yeti_web.yml') }
      .to raise_error(YetiConfigLoader::Error, /outdated config .*logs moved under `logging`/)
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

    # `logs` and `elasticsearch` moved under `logging`. Nothing else rejects them: the
    # `validate_keys` of dry-schema cannot be turned on while the config has free form
    # blocks, so an unknown key is ignored and the logs would silently stop being shipped.
    # YetiConfig is defined by the load itself: stubbing it before the call would make
    # .call return early, as it does for an already loaded config.
    def stub_loaded_config(settings)
      allow(Config).to receive(:load_and_set_settings) { stub_const('YetiConfig', OpenStruct.new(settings)) }
    end

    %i[logs elasticsearch].each do |key|
      it "rejects the outdated top level `#{key}` key" do
        stub_loaded_config(key => {})

        expect { described_class.call }
          .to raise_error(YetiConfigLoader::Error, /outdated config .*#{key} moved under `logging`/)
      end
    end

    it 'accepts a config that uses the current keys' do
      stub_loaded_config(logging: {})

      expect { described_class.call }.not_to raise_error
    end

    it 'reports an invalid config as its own error, not the gem class' do
      allow(Config).to receive(:load_and_set_settings)
        .and_raise(Config::Validation::Error, 'site_title: must be a string')

      expect { described_class.call }
        .to raise_error(YetiConfigLoader::Error, /invalid config .*yeti_web\.yml: site_title: must be a string/)
    end
  end
end
