RSpec.describe IPAddr do

  describe '#cidr_mask' do

    subject do
      described_class.new(ip).cidr_mask
    end

    context 'with valid IPv4' do
      let(:ip) { '192.168.0.0/16' }

      it { is_expected.to eq(16) }
    end

    context 'with valid IPv6' do
      let(:ip) { '2001:67c:1324:111::1/64' }

      it { is_expected.to eq(64) }
    end

    context 'with invalid IPv4' do
      let(:ip) { '1.1.1.1/34' }

      it { expect { subject }.to raise_error(IPAddr::InvalidPrefixError) }
    end

    context 'with invalid IPv6' do
      let(:ip) { '2001:67c:1324:111::1/129' }

      it { expect { subject }.to raise_error(IPAddr::InvalidPrefixError) }
    end
  end

end

