# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Routing::RoutingTagMode, type: :model do
  describe '#and?' do
    subject { described_class.new(id: id).and? }

    context 'AND' do
      let(:id) { 1 }
      it { is_expected.to eq(true) }
    end

    context 'OR' do
      let(:id) { 0 }
      it { is_expected.to eq(false) }
    end
  end
end
