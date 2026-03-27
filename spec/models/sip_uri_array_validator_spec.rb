# frozen_string_literal: true

RSpec.describe SipUriArrayValidator do
  subject(:record) { gateway }

  let(:gateway) { FactoryBot.build(:gateway) }

  describe 'term_route_set validation' do
    context 'when empty' do
      before { gateway.term_route_set = [] }

      it { is_expected.to be_valid }
    end

    context 'with valid sip: URIs' do
      before { gateway.term_route_set = ['sip:proxy.example.com;transport=udp', 'sip:proxy2.example.com;transport=tcp'] }

      it { is_expected.to be_valid }
    end

    context 'with valid sips: URI' do
      before { gateway.term_route_set = ['sips:proxy.example.com;transport=tls'] }

      it { is_expected.to be_valid }
    end

    context 'with invalid URI (no scheme)' do
      before { gateway.term_route_set = ['proxy.example.com;transport=udp'] }

      it { is_expected.not_to be_valid }

      it 'has error on term_route_set' do
        gateway.valid?
        expect(gateway.errors[:term_route_set]).to be_present
      end
    end

    context 'with invalid URI (empty string)' do
      before { gateway.term_route_set = [''] }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'orig_route_set validation' do
    context 'when empty' do
      before { gateway.orig_route_set = [] }

      it { is_expected.to be_valid }
    end

    context 'with valid sip: URI' do
      before { gateway.orig_route_set = ['sip:proxy.example.com;transport=udp'] }

      it { is_expected.to be_valid }
    end

    context 'with invalid URI (no scheme)' do
      before { gateway.orig_route_set = ['not-a-sip-uri'] }

      it { is_expected.not_to be_valid }

      it 'has error on orig_route_set' do
        gateway.valid?
        expect(gateway.errors[:orig_route_set]).to be_present
      end
    end
  end
end
