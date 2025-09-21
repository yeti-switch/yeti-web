# frozen_string_literal: true

require 'spec_helper'

require File.join(File.dirname(__FILE__), '../../processors/cdr_stat')
require File.join(File.dirname(__FILE__), '../../models/cdr_base')

RSpec.describe CdrStat do
  subject do
    consumer.perform_batch
  end

  cfg = begin
    f = YAML.safe_load(ERB.new(File.read('../config/database.yml')).result, aliases: true)
    {
      'mode' => 'test',
      'databases' => f.to_h,
      'stored_procedure' => 'switch.async_cdr_statistics'
    }
  end

  let(:consumer) do
    described_class.new(TestContext.logger, nil, nil, cfg)
  end
  let(:database_config) do
    cfg['databases']['test']['cdr']
  end
  let(:expected_sql) do
    "SELECT processed_records FROM #{cfg['stored_procedure']}()"
  end

  before do
    allow(::CdrBase).to receive(:establish_connection).once.with(database_config) { true }
    allow(::CdrBase).to receive(:fetch_sp_val).once.with(expected_sql).and_return(return_value)
  end

  context 'when stored_procedure returns 3' do
    let(:return_value) { '3' }

    it 'returns 3' do
      expect(subject).to eq 3
    end
  end

  context 'when stored_procedure returns 0' do
    let(:return_value) { '0' }

    it 'returns -1' do
      expect(subject).to eq -1
    end
  end

  context 'when stored_procedure returns null' do
    let(:return_value) { nil }

    it 'returns 0' do
      expect(subject).to eq 0
    end
  end
end
