# frozen_string_literal: true

RSpec.describe SipUriParser do
  describe '.parse' do
    subject { described_class.parse(input) }

    context 'with nil input' do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end

    context 'with empty string' do
      let(:input) { '' }

      it { is_expected.to be_nil }
    end

    context 'with blank string' do
      let(:input) { '   ' }

      it { is_expected.to be_nil }
    end

    context 'with simple sip URI' do
      let(:input) { 'sip:12345@example.com' }

      it 'parses schema, user and host' do
        expect(subject).to eq(
          's' => 'sip',
          'n' => nil,
          'u' => '12345',
          'h' => 'example.com',
          'p' => nil,
          'up_arr' => [],
          'uh_arr' => [],
          'np_arr' => []
        )
      end
    end

    context 'with sip URI and port' do
      let(:input) { 'sip:user@host.com:5060' }

      it 'parses port' do
        expect(subject).to include(
          's' => 'sip',
          'u' => 'user',
          'h' => 'host.com',
          'p' => 5060
        )
      end
    end

    context 'with sips URI' do
      let(:input) { 'sips:user@secure.example.com' }

      it 'parses sips schema' do
        expect(subject).to include('s' => 'sips', 'u' => 'user', 'h' => 'secure.example.com')
      end
    end

    context 'with tel URI' do
      let(:input) { 'tel:+1234567890' }

      it 'parses tel schema and number' do
        expect(subject).to eq(
          's' => 'tel',
          'n' => nil,
          'u' => '+1234567890',
          'h' => nil,
          'p' => nil,
          'up_arr' => [],
          'uh_arr' => [],
          'np_arr' => []
        )
      end
    end

    context 'with tel URI and parameters' do
      let(:input) { 'tel:+1234567890;phone-context=example.com;npdi' }

      it 'parses tel parameters into up_arr' do
        expect(subject).to include(
          's' => 'tel',
          'u' => '+1234567890',
          'up_arr' => ['phone-context=example.com', 'npdi']
        )
      end
    end

    context 'with angle brackets' do
      let(:input) { '<sip:user@host.com>' }

      it 'parses URI inside angle brackets' do
        expect(subject).to include(
          's' => 'sip',
          'n' => nil,
          'u' => 'user',
          'h' => 'host.com'
        )
      end
    end

    context 'with display name and angle brackets' do
      let(:input) { '"John Doe" <sip:john@example.com>' }

      it 'parses display name' do
        expect(subject).to include(
          's' => 'sip',
          'n' => 'John Doe',
          'u' => 'john',
          'h' => 'example.com'
        )
      end
    end

    context 'with unquoted display name' do
      let(:input) { 'John Doe <sip:john@example.com>' }

      it 'parses unquoted display name' do
        expect(subject).to include('n' => 'John Doe')
      end
    end

    context 'with URI parameters' do
      let(:input) { 'sip:user@host.com;transport=udp;lr' }

      it 'parses URI parameters into up_arr' do
        expect(subject).to include(
          'u' => 'user',
          'h' => 'host.com',
          'up_arr' => ['transport=udp', 'lr']
        )
      end
    end

    context 'with URI headers' do
      let(:input) { 'sip:user@host.com?subject=test&priority=urgent' }

      it 'parses URI headers into uh_arr' do
        expect(subject).to include(
          'u' => 'user',
          'h' => 'host.com',
          'uh_arr' => ['subject=test', 'priority=urgent']
        )
      end
    end

    context 'with header parameters after angle brackets' do
      let(:input) { '<sip:user@host.com>;tag=abc;epid=xyz' }

      it 'parses header parameters into np_arr' do
        expect(subject).to include(
          'u' => 'user',
          'h' => 'host.com',
          'np_arr' => ['tag=abc', 'epid=xyz']
        )
      end
    end

    context 'with full SIP URI (all components)' do
      let(:input) { '"Alice" <sip:alice@atlanta.com:5060;transport=tcp?subject=call>;tag=1928301774' }

      it 'parses all parts correctly' do
        expect(subject).to eq(
          's' => 'sip',
          'n' => 'Alice',
          'u' => 'alice',
          'h' => 'atlanta.com',
          'p' => 5060,
          'up_arr' => ['transport=tcp'],
          'uh_arr' => ['subject=call'],
          'np_arr' => ['tag=1928301774']
        )
      end
    end

    context 'with IPv6 host' do
      let(:input) { 'sip:user@[::1]:5060' }

      it 'parses IPv6 address and port' do
        expect(subject).to include(
          'u' => 'user',
          'h' => '::1',
          'p' => 5060
        )
      end
    end

    context 'with IPv6 host without port' do
      let(:input) { 'sip:user@[2001:db8::1]' }

      it 'parses IPv6 address' do
        expect(subject).to include(
          'u' => 'user',
          'h' => '2001:db8::1',
          'p' => nil
        )
      end
    end

    context 'with URI without userpart' do
      let(:input) { 'sip:example.com' }

      it 'treats it as host only' do
        expect(subject).to include(
          's' => 'sip',
          'u' => nil,
          'h' => 'example.com'
        )
      end
    end

    context 'with port and URI params' do
      let(:input) { 'sip:user@host.com:5080;transport=tls' }

      it 'parses port and params correctly' do
        expect(subject).to include(
          'h' => 'host.com',
          'p' => 5080,
          'up_arr' => ['transport=tls']
        )
      end
    end

    context 'with case-insensitive scheme' do
      let(:input) { 'SIP:user@host.com' }

      it 'normalizes scheme to lowercase' do
        expect(subject).to include('s' => 'sip')
      end
    end
  end

  describe '.parse_multiple' do
    subject { described_class.parse_multiple(input) }

    context 'with nil input' do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end

    context 'with empty string' do
      let(:input) { '' }

      it { is_expected.to be_nil }
    end

    context 'with a single URI' do
      let(:input) { 'sip:user@host.com' }

      it 'returns an array with one parsed URI' do
        expect(subject).to eq([
                                { 's' => 'sip', 'n' => nil, 'u' => 'user', 'h' => 'host.com',
                                  'p' => nil, 'up_arr' => [], 'uh_arr' => [], 'np_arr' => [] }
                              ])
      end
    end

    context 'with two comma-separated plain URIs' do
      let(:input) { 'sip:alice@atlanta.com, sip:bob@biloxi.com' }

      it 'returns two parsed URIs' do
        expect(subject.length).to eq(2)
        expect(subject[0]).to include('u' => 'alice', 'h' => 'atlanta.com')
        expect(subject[1]).to include('u' => 'bob', 'h' => 'biloxi.com')
      end
    end

    context 'with comma-separated URIs in angle brackets with header params' do
      let(:input) { '<sip:+123@gw1.example.com>;reason=unconditional, <sip:+456@gw2.example.com>;reason=no-answer' }

      it 'splits correctly on comma outside brackets' do
        expect(subject.length).to eq(2)
        expect(subject[0]).to include('u' => '+123', 'h' => 'gw1.example.com', 'np_arr' => ['reason=unconditional'])
        expect(subject[1]).to include('u' => '+456', 'h' => 'gw2.example.com', 'np_arr' => ['reason=no-answer'])
      end
    end

    context 'with comma-separated URIs with display names' do
      let(:input) { '"Alice" <sip:alice@atlanta.com>, "Bob" <sip:bob@biloxi.com>' }

      it 'parses display names for each URI' do
        expect(subject.length).to eq(2)
        expect(subject[0]).to include('n' => 'Alice', 'u' => 'alice')
        expect(subject[1]).to include('n' => 'Bob', 'u' => 'bob')
      end
    end

    context 'with three comma-separated URIs' do
      let(:input) { 'sip:a@one.com, sip:b@two.com, sip:c@three.com' }

      it 'returns three parsed URIs' do
        expect(subject.length).to eq(3)
        expect(subject[0]).to include('u' => 'a', 'h' => 'one.com')
        expect(subject[1]).to include('u' => 'b', 'h' => 'two.com')
        expect(subject[2]).to include('u' => 'c', 'h' => 'three.com')
      end
    end

    context 'with mixed URI types' do
      let(:input) { 'sip:user@host.com, tel:+1234567890' }

      it 'parses each URI type correctly' do
        expect(subject.length).to eq(2)
        expect(subject[0]).to include('s' => 'sip', 'u' => 'user')
        expect(subject[1]).to include('s' => 'tel', 'u' => '+1234567890')
      end
    end
  end
end
