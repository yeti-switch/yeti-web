# frozen_string_literal: true

RSpec.describe HttpxProxy do
  def session_options(proxy, session = HTTPX.with({}))
    proxy.apply(session).instance_variable_get(:@options)
  end

  describe '#apply' do
    context 'when an explicit proxy is configured' do
      subject(:proxy) { described_class.new(http_proxy: 'http://proxy.local:3128') }

      it 'adds the proxy to the session' do
        expect(session_options(proxy).proxy.uri.to_s).to eq 'http://proxy.local:3128'
      end
    end

    context 'when no explicit proxy is configured' do
      subject(:proxy) { described_class.new(http_proxy: nil, use_env_proxy: false) }

      # HTTPX loads its :proxy plugin globally when a *_PROXY env var is present
      # (e.g. HTTPS_PROXY on CI), so the options may respond to #proxy regardless.
      # What matters is that no explicit proxy was set on the session.
      it 'leaves the session without an explicit proxy' do
        expect(session_options(proxy).try(:proxy)).to be_nil
      end
    end
  end

  describe '#inherit_env_proxy?' do
    it 'is false when an explicit proxy is configured (it wins over env)' do
      expect(described_class.new(http_proxy: 'http://p:3128', use_env_proxy: true)).to_not be_inherit_env_proxy
    end

    it 'is true when no explicit proxy is set and use_env_proxy is enabled' do
      expect(described_class.new(http_proxy: nil, use_env_proxy: true)).to be_inherit_env_proxy
    end

    it 'is false when use_env_proxy is disabled or unset' do
      expect(described_class.new(http_proxy: nil, use_env_proxy: false)).to_not be_inherit_env_proxy
      expect(described_class.new(http_proxy: nil)).to_not be_inherit_env_proxy
    end
  end

  describe '#run' do
    let(:original_https_proxy) { ENV.fetch('HTTPS_PROXY', nil) }

    before { ENV['HTTPS_PROXY'] = 'http://env.proxy:3128' }
    after { original_https_proxy.nil? ? ENV.delete('HTTPS_PROXY') : ENV['HTTPS_PROXY'] = original_https_proxy }

    context 'when inheriting the env proxy' do
      subject(:proxy) { described_class.new(http_proxy: nil, use_env_proxy: true) }

      it 'leaves the proxy env vars visible to the request' do
        seen = 'not-yielded'
        result = proxy.run { seen = ENV.fetch('HTTPS_PROXY', nil) }

        expect(seen).to eq 'http://env.proxy:3128'
        expect(result).to eq 'http://env.proxy:3128'
      end
    end

    context 'when not inheriting the env proxy' do
      subject(:proxy) { described_class.new(http_proxy: nil, use_env_proxy: false) }

      it 'hides the proxy env vars for the request and restores them afterwards' do
        seen = 'not-yielded'
        proxy.run { seen = ENV.fetch('HTTPS_PROXY', nil) }

        expect(seen).to be_nil
        expect(ENV.fetch('HTTPS_PROXY', nil)).to eq 'http://env.proxy:3128'
      end

      it 'restores the proxy env vars even when the request raises' do
        expect { proxy.run { raise 'boom' } }.to raise_error('boom')
        expect(ENV.fetch('HTTPS_PROXY', nil)).to eq 'http://env.proxy:3128'
      end

      it 'returns the block result' do
        expect(proxy.run { 42 }).to eq 42
      end
    end
  end
end
