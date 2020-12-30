# frozen_string_literal: true

require 'spec_helper'
require 'uri'

require File.join(File.dirname(__FILE__), '../../processors/cdr_http')

RSpec.describe CdrHttp do
  let(:cdrs) do
    [
      { id: 1, duration: 2 },
      { id: 2, duration: 2 }
    ]
  end

  let(:consumer) { CdrHttp.new(TestContext.logger, 'cdr_billing', 'cdr_http', config) }
  let(:method) { 'POST' }
  let(:cdr_fields) { 'all' }
  let(:config) do
    {
      'url' => 'https://external-endpoint/api/cdr',
      'method' => method,
      'cdr_fields' => cdr_fields
    }
  end

  before :each do
    allow(consumer).to receive(:config).and_return config
    stub_request config['method'].downcase.to_sym, /#{config['url']}/
    subject
  end

  subject { consumer.perform_group cdrs }

  context 'permit all attributes' do
    it { expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 1, duration: 2 }) }
    it { expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 2, duration: 2 }) }
  end

  context 'permit array attribute' do
    let(:cdr_fields) { ['id'] }

    it { expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 1 }) }
    it { expect(WebMock).to have_requested(:post, config['url']).with(body: { id: 2 }) }
  end

  context 'GET method' do
    let(:method) { 'GET' }

    it { expect(WebMock).to have_requested(:get, "#{config['url']}?#{URI.encode_www_form cdrs[0]}") }
    it { expect(WebMock).to have_requested(:get, "#{config['url']}?#{URI.encode_www_form cdrs[1]}") }
  end
end
