# frozen_string_literal: true

require_relative Rails.root.join('lib/yeti_config_schema')

RSpec.describe YetiConfigSchema do
  subject { schema.call(config).errors.to_h.dig(:logging, :victorialogs, :url) }

  # Built on an object of its own, so that the global Config keeps the schema it has.
  let(:schema) do
    Object.new.extend(Config::Validation::Schema).tap { |setup_config| described_class.apply(setup_config) }.schema
  end
  let(:config) { YetiConfig.to_h.deep_merge(logging: { victorialogs: { url: } }) }

  describe 'logging.victorialogs.url' do
    [
      nil,
      '',
      'http://localhost:9428/insert/jsonline?_msg_field=message&_stream_fields=host,component',
      'https://victorialogs.example.com/insert/jsonline'
    ].each do |value|
      context "when it is #{value.inspect}" do
        let(:url) { value }

        it { is_expected.to be_nil }
      end
    end

    # Every one of these makes SemanticLogger::Appender::Http raise while it is built,
    # which the after_initialize of config/initializers/semantic_logger.rb does not rescue.
    [
      'localhost:9428',
      '/insert/jsonline',
      'not a url',
      'http://localhost:9428/insert/jsonline?_stream_fields=host, component',
      'ftp://localhost/insert/jsonline'
    ].each do |value|
      context "when it is #{value.inspect}" do
        let(:url) { value }

        it { is_expected.to eq ['is in invalid format'] }
      end
    end
  end

  describe 'oauth.issuer' do
    subject { schema.call(config).errors.to_h.dig(:oauth, :issuer) }

    let(:config) { YetiConfig.to_h.deep_merge(oauth: { issuer: }) }

    [nil, 'https://web.example.com', 'http://127.0.0.1:3000', 'https://[2001:db8::1]:8443'].each do |value|
      context "when it is #{value.inspect}" do
        let(:issuer) { value }

        it { is_expected.to be_nil }
      end
    end

    # MCP clients fetch <issuer>/.well-known/oauth-authorization-server, routed at the root only.
    [
      'https://web.example.com/',
      'https://web.example.com/oauth',
      'https://web.example.com?tenant=yeti',
      'https://web.example.com#yeti',
      'https://user@web.example.com',
      'https://web.example.com\\oauth',
      'https://web.example.com:abc',
      'https://web.example.com:',
      '',
      'web.example.com'
    ].each do |value|
      context "when it is #{value.inspect}" do
        let(:issuer) { value }

        it { is_expected.to eq ['is in invalid format'] }
      end
    end
  end
end
