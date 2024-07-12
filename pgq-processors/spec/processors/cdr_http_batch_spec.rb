# frozen_string_literal: true

require 'spec_helper'
require 'uri'

require File.join(File.dirname(__FILE__), '../../processors/cdr_http_batch')

RSpec.describe CdrHttpBatch do
  subject do
    consumer.perform_group(cdrs)
  end

  let(:cdrs) do
    [
      { id: 1, duration: 2 },
      { id: 2, duration: 2 }
    ]
  end
  let(:consumer) { CdrHttpBatch.new(TestContext.logger, 'cdr_billing', 'cdr_http_batch', config) }
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
    stub_request :post, /#{config['url']}/
  end

  context 'permit all attributes' do
    it 'sends POST request with cdrs data' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
      expect(WebMock).to have_requested(:post, config['url']).with(
        body: {
          data: [
            { id: 1, duration: 2 },
            { id: 2, duration: 2 }
          ]
        }
      )
    end
  end

  context 'when config has data_filters' do
    let(:config) do
      super().merge 'data_filters' => [
        { field: 'id', op: 'eq', value: 1 },
        { field: 'duration', op: 'gt', value: 0 }
      ]
    end
    let(:cdrs) do
      [
        { id: 1, duration: 2 },
        { id: 1, duration: 3 },
        { id: 2, duration: 2 },
        { id: 1, duration: 0 }
      ]
    end

    it 'sends POST request with cdrs data' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
      expect(WebMock).to have_requested(:post, config['url']).with(
        body: {
          data: [
            { id: 1, duration: 2 },
            { id: 1, duration: 3 }
          ]
        }
      )
    end

    context 'when all events are filtered out' do
      let(:config) do
        super().merge 'data_filters' => [
          { field: 'id', op: 'eq', value: 2 },
          { field: 'duration', op: 'gt', value: 0 }
        ]
      end
      let(:cdrs) do
        [
          { id: 1, duration: 2 },
          { id: 2, duration: 0 },
          { id: 1, duration: 0 }
        ]
      end

      it 'sends POST request with cdrs data' do
        subject
        expect(WebMock).not_to have_requested(:post, config['url'])
      end
    end
  end

  context 'permit array attribute' do
    let(:cdr_fields) { ['id'] }

    it 'sends POST request with cdrs data' do
      subject
      expect(WebMock).to have_requested(:post, config['url']).once
      expect(WebMock).to have_requested(:post, config['url']).with(
        body: {
          data: [
            { id: 1 },
            { id: 2 }
          ]
        }
      )
    end
  end
end
