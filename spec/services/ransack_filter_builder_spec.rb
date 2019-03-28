# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RansackFilterBuilder do
  let(:builder) { RansackFilterBuilder.new(attr: attr, operator: operator) }
  let(:attr) { 'name' }

  describe '#verify' do
    let(:values) { [1, 2] }
    subject { builder.verify(values) }

    context 'when operator is "in"' do
      let(:operator) { 'in' }
      it { is_expected.to eq values }
    end
    context 'when operator is "not_in"' do
      let(:operator) { 'not_in' }
      it { is_expected.to eq values }
    end
    context 'when operator is "not_in"' do
      let(:operator) { 'cont_any' }
      it { is_expected.to eq values }
    end
    context 'when operator is not array ransack operator' do
      let(:operator) { 'eq' }
      context 'when value.size !== 1' do
        it { expect { subject }.to raise_error(JSONAPI::Exceptions::InvalidFilterValue) }
      end
      context 'when value.size == 1' do
        let(:values) { [1] }
        it { is_expected.to eq values.first }
      end
    end
  end

  describe '#apply' do
    let(:records) { double 'records' }
    let(:ransack_result) { double 'ransack_result' }
    let(:operator) { 'eq' }
    let(:value) { 'str' }

    before do
      allow(ransack_result).to receive(:result)
      expect(records).to receive(:ransack).with('name_eq' => value).and_return(ransack_result)
    end

    it 'builds correct ransack operator' do
      builder.apply(records, value)
    end
  end

  describe '#filter_name' do
    let(:operator) { 'eq' }
    subject { builder.filter_name }
    it { is_expected.to eq "#{attr}_eq" }
  end
end
