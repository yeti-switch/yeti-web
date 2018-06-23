RSpec.describe CustomersAuth, type: :model do

  shared_examples :it_validates_array_elements do |*columns|
    columns.each do |column_name|
      # uniquness
      it { is_expected.not_to allow_value(['127.0.0.1', '127.0.0.1']).for(column_name) }
      it { is_expected.to allow_value(['127.0.0.1', '127.0.0.2']).for(column_name) }
      # spaces are not allowed
      it { is_expected.not_to allow_value(['s s', 'asd']).for(column_name) }
      it { is_expected.not_to allow_value(['asd', 'a sd']).for(column_name) }
    end
  end


  context '#validations' do

    it do
      is_expected.to validate_numericality_of(:capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    end


    context 'validate Routing Tag' do
      include_examples :test_model_with_tag_action
    end

    context 'validate match condition attributes' do

      include_examples :it_validates_array_elements,
        :ip,
        :dst_prefix, :src_prefix,
        :uri_domain, :from_domain, :to_domain,
        :x_yeti_auth
    end

    context 'ip' do
      it { is_expected.not_to allow_value([]).for(:ip) }
    end
  end

  context 'scope :ip_covers' do
    before do
      @record = create(:customers_auth, ip: ['127.0.0.1', '127.0.0.2'])
      @record_2 = create(:customers_auth, ip: ['127.0.0.2', '127.0.0.3'])
      create(:customers_auth, ip: ['127.0.0.4'])
    end

    let(:expected_found_records) do
      [@record_2.id, @record.id]
    end

    subject do
      described_class.ip_covers(ip)
    end

    context 'IP found' do
      let(:ip) { '127.0.0.2' }

      it 'finds expected records' do
        expect(subject.pluck(:id)).to match_array(expected_found_records)
      end
    end

    context 'IP not found' do
      let(:ip) { '127.0.0.9' }

      it 'finds nothing' do
        expect(subject.pluck(:id)).to match_array([])
      end
    end

    context 'invalid IP' do
      let(:ip) { 'asdkjhasdkl jhasd ' }

      it 'should no fail and finds nothing' do
        expect(subject.pluck(:id)).to match_array([])
      end
    end

  end

end
