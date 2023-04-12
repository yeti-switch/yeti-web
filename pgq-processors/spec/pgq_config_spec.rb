# frozen_string_literal: true

require_relative '../pgq_config'

RSpec.describe PgqConfig do
  subject do
    described_class.new(config_file, section)
  end

  let(:config_file) { File.expand_path('fixtures/yaml/test_config.yml', __dir__) }
  let(:section) { 'some' }

  it 'does not raise error' do
    expect { subject }.not_to raise_error
  end

  it 'has correct config' do
    expect(subject.config).to be_kind_of(Hash)
  end
end
