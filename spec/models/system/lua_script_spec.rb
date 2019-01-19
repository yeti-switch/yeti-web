# frozen_string_literal: true

require 'spec_helper'

describe System::LuaScript, type: :model do
  describe 'validations' do
    subject do
      described_class.create(name: 'lua script', source: '...')
    end

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :source }

    it { is_expected.to validate_uniqueness_of :name }
  end
end
