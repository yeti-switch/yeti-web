# frozen_string_literal: true

RSpec.describe Cdr::CdrPolicy do
  let(:admin_user) { FactoryBot.build(:admin_user, roles: user_roles) }
  let(:policy) { described_class.new(admin_user, nil) }

  before do
    stub_const('Rails', Class.new) unless defined?(Rails)
    allow(Rails).to receive(:configuration).and_return(OpenStruct.new(policy_roles: policy_roles_config))
  end

  shared_examples 'policy_method' do |method:, key:|
    context 'when AdminUser is root' do
      let(:user_roles) { [:root] }
      let(:policy_roles_config) { { root: { :'Cdr/Cdr' => { key => true } } } }

      it 'returns true' do
        expect(policy.public_send(method)).to eq true
      end
    end

    context 'when AdminUser has only role "user" and policy allows' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) do
        {
          user: {
            :'Cdr/Cdr' => { key => true }
          }
        }
      end

      it 'returns true' do
        expect(policy.public_send(method)).to eq true
      end
    end

    context 'when AdminUser has only role "user" and policy disallows' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) do
        {
          user: {
            :'Cdr/Cdr' => { key => false }
          }
        }
      end

      it 'returns false' do
        expect(policy.public_send(method)).to eq false
      end
    end

    context 'when AdminUser has only role "user" and policy section exists but rule missing' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) do
        {
          user: {
            :'Cdr/Cdr' => { some_other_key: true }
          }
        }
      end

      it 'returns false' do
        expect(policy.public_send(method)).to eq false
      end
    end

    context 'when AdminUser has only role "user" and policy section missing' do
      let(:user_roles) { [:user] }
      let(:policy_roles_config) do
        {
          user: {
            OtherSection: { key => true }
          }
        }
      end

      it 'returns false' do
        expect(policy.public_send(method)).to eq false
      end
    end
  end

  describe '#download_call_record?' do
    it_behaves_like 'policy_method', method: :download_call_record?, key: :recording
  end

  describe '#dump?' do
    it_behaves_like 'policy_method', method: :dump?, key: :pcap
  end

  describe '#allow_full_dst_number?' do
    it_behaves_like 'policy_method', method: :allow_full_dst_number?, key: :allow_full_dst_number
  end
end
