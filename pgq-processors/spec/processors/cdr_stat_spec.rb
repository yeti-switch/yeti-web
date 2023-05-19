# frozen_string_literal: true

require 'spec_helper'

require File.join(File.dirname(__FILE__), '../../processors/cdr_stat')
require File.join(File.dirname(__FILE__), '../../models/routing_base')

RSpec.describe CdrStat do
  subject do
    consumer.perform_batch
  end

  CONFIG = begin
    f = YAML.safe_load(ERB.new(File.read('../config/database.yml')).result, aliases: true)
    {
      'mode' => 'test',
      'databases' => f.to_h,
      'stored_procedure' => 'switch.async_cdr_statistics'
    }
  end

  let(:consumer) do
    described_class.new(TestContext.logger, nil, nil, CONFIG)
  end
  let(:database_config) do
    CONFIG['databases']['test']['primary']
  end
  let(:expected_sql) do
    "SELECT processed_records FROM #{CONFIG['stored_procedure']}()"
  end

  context 'when stored_procedure returns 3' do
    before do
      allow(::RoutingBase).to receive(:establish_connection).once.with(database_config) { true }
      allow(::RoutingBase).to receive(:fetch_sp_val).once.with(expected_sql).and_return('3')
    end

    it 'returns 3' do
      expect(subject).to eq 3
    end
  end

  context 'when stored_procedure returns 0' do
    before do
      allow(::RoutingBase).to receive(:establish_connection).once.with(database_config) { true }
      allow(::RoutingBase).to receive(:fetch_sp_val).once.with(expected_sql).and_return('0')
    end

    it 'returns -1' do
      expect(subject).to eq -1
    end
  end

  context 'when stored_procedure returns null' do
    before do
      allow(::RoutingBase).to receive(:establish_connection).once.with(database_config) { true }
      allow(::RoutingBase).to receive(:fetch_sp_val).once.with(expected_sql).and_return(nil)
    end

    it 'returns 0' do
      expect(subject).to eq 0
    end
  end
end
