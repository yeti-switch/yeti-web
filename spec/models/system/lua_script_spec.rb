# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.lua_scripts
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  source     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

RSpec.describe System::LuaScript, type: :model do
  describe 'validations' do
    subject do
      described_class.create(name: 'lua script', source: '...')
    end

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :source }

    it { is_expected.to validate_uniqueness_of :name }
  end
end
