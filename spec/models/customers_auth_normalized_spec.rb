RSpec.describe CustomersAuthNormalized, type: :model do

  shared_examples :test_normalized_copy_count do |copy_count|
    it 'creates only one CustomersAuth' do
      expect { subject }.to change { CustomersAuth.count }.by(1)
    end

    it 'create denormalized copies' do
      expect { subject }.to change { described_class.count }.by(copy_count)
    end

    it 'create denormalized copies linked to original' do
      subject
      copies = described_class.where(customers_auth_id: CustomersAuth.take.id)
      expect(copies.count).to eq(copy_count)
    end
  end


  describe '#create' do

    subject { create(:customers_auth, attributes) }

    context 'when all attributes are ampty (default DB values)' do
      let(:attributes) do
        {
          # ip: [], default 127.0.0.0/8
          src_prefix: [],
          dst_prefix: [],
          uri_domain: [],
          from_domain: [],
          to_domain: [],
          x_yeti_auth: []
        }
      end

      include_examples :test_normalized_copy_count, 1

      it 'create copy with empty match-conditions attributes' do
        subject
        expect(described_class.take).to have_attributes(
          ip: '127.0.0.0/8',
          src_prefix: '',
          dst_prefix: '',
          uri_domain: nil,
          from_domain: nil,
          to_domain: nil,
          x_yeti_auth: nil
        )
      end
    end

    context 'when all attributes are filled in with single value' do
      let(:attributes) do
        {
          ip: ['127.0.0.1'],
          src_prefix: ['src-p-1'],
          dst_prefix: ['dst-p-1'],
          uri_domain: ['uri-1'],
          from_domain: ['from-1'],
          to_domain: ['to-1'],
          x_yeti_auth: ['x-1']
        }
      end

      include_examples :test_normalized_copy_count, 1

      it 'creates denormalized copy with expected attributes' do
        subject
        expect(described_class.take).to have_attributes(
          ip: IPAddr.new('127.0.0.1'),
          src_prefix: 'src-p-1',
          dst_prefix: 'dst-p-1',
          uri_domain: 'uri-1',
          from_domain: 'from-1',
          to_domain: 'to-1',
          x_yeti_auth: 'x-1'
        )
      end
    end

    context 'when only IPs is filled with several values' do
      let(:attributes) do
        {
          ip: ['127.0.0.1', '192.168.0.1'],
          src_prefix: [],
          dst_prefix: [],
          uri_domain: [],
          from_domain: [],
          to_domain: [],
          x_yeti_auth: []
        }
      end

      include_examples :test_normalized_copy_count, 2

      it 'creates denormalized copies with expected IP' do
        subject
        expect(described_class.first).to have_attributes(ip: IPAddr.new('127.0.0.1'))
        expect(described_class.second).to have_attributes(ip: IPAddr.new('192.168.0.1'))
      end
    end


    context 'when only SRC_PREFIXES is filled with several values' do
      let(:attributes) do
        {
          # ip: [], default
          src_prefix: ['src-1', 'src-2'],
          dst_prefix: [],
          uri_domain: [],
          from_domain: [],
          to_domain: [],
          x_yeti_auth: []
        }
      end

      include_examples :test_normalized_copy_count, 2

      it 'creates denormalized copies with expected SRC_PREFIX' do
        subject
        expect(described_class.first).to have_attributes(src_prefix: 'src-1')
        expect(described_class.second).to have_attributes(src_prefix: 'src-2')
      end
    end

    context 'when all attribtes are filled with several values' do
      let(:attributes) do
        {
          ip: ['127.0.0.1', '192.168.0.1'],
          src_prefix: ['src-1', 'src-2'],
          dst_prefix: ['dst-1', 'dst-2'],
          uri_domain: ['uri-1', 'uri-2'],
          from_domain: ['from-1', 'from-2'],
          to_domain: ['to-1', 'to-2'],
          x_yeti_auth: ['x-1', 'x-2']
        }
      end

      # https://en.wikipedia.org/wiki/Cartesian_product
      # ips.count * src_prefixes.count * ... * x_yeti_auths.count
      include_examples :test_normalized_copy_count, 128

      it 'creates expected denormalized copy(test first and last)' do
        subject
        expect(described_class.first).to have_attributes(
          ip: IPAddr.new('127.0.0.1'),
          src_prefix: 'src-1',
          dst_prefix: 'dst-1',
          uri_domain: 'uri-1',
          from_domain: 'from-1',
          to_domain: 'to-1',
          x_yeti_auth: 'x-1'
        )
        expect(described_class.last).to have_attributes(
          ip: IPAddr.new('192.168.0.1'),
          src_prefix: 'src-2',
          dst_prefix: 'dst-2',
          uri_domain: 'uri-2',
          from_domain: 'from-2',
          to_domain: 'to-2',
          x_yeti_auth: 'x-2'
        )
      end
    end

    context 'when error happens with last denormalized copy' do
      let(:attributes) do
        {
          ip: ['127.0.0.1'],
          src_prefix: ['src-1', 'src-2'],
          dst_prefix: ['dst-1'],
          uri_domain: ['uri-1'],
          from_domain: ['from-1'],
          to_domain: ['to-1'],
          x_yeti_auth: ['x-1']
        }
      end

      before do
        allow(CustomersAuthNormalized).to receive(:create!).with(a_hash_including(src_prefix: 'src-1')).and_call_original
        allow(CustomersAuthNormalized).to receive(:create!).with(a_hash_including(src_prefix: 'src-2')).and_raise(ActiveRecord::StatementInvalid, 'null value in column "customers_auth_id" violates not-null constraint')
      end

      it 'rollback all' do
        subject rescue nil
        expect(described_class.count).to eq(0)
        expect(CustomersAuth.count).to eq(0)
      end
    end

    context 'when error happens with first and only denormalized copy' do
      let(:attributes) do
        {
          # ip: [], default
          src_prefix: [],
          dst_prefix: [],
          uri_domain: [],
          from_domain: [],
          to_domain: [],
          x_yeti_auth: []
        }
      end

      before do
        allow(CustomersAuthNormalized).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, 'null value in column "customers_auth_id" violates not-null constraint')
      end

      it 'rollback all' do
        subject rescue nil
        expect(described_class.count).to eq(0)
        expect(CustomersAuth.count).to eq(0)
      end
    end
  end


  describe '#update' do
    let!(:record) do
      create(:customers_auth,
             src_rewrite_rule: old_src_rewrite_rule,
             ip: ['127.0.0.1', '192.168.0.1'],
             src_prefix: ['src-1', 'src-2'],
             dst_prefix: ['dst-1', 'dst-2'],
             uri_domain: ['uri-1', 'uri-2'],
             from_domain: ['from-1', 'from-2'],
             to_domain: ['to-1', 'to-2'],
             x_yeti_auth: ['x-1', 'x-2'])
    end

    let(:old_src_rewrite_rule) { 'old-value'  }

    subject { record.update!(attributes) }

    context 'when update a matching-condition attribute' do
      let(:attributes) do
        {
          src_prefix: ['src-3', 'src-4']
        }
      end

      it 'updates copies' do
        # we have total 128 copies, 64 for each src_prefix entity
        expect(described_class.where(src_prefix: 'src-1').count).to eq(64)
        expect(described_class.where(src_prefix: 'src-2').count).to eq(64)
        subject
        # after update this records should not be
        expect(described_class.where(src_prefix: 'src-1').count).to eq(0)
        expect(described_class.where(src_prefix: 'src-2').count).to eq(0)
        # instead we have this
        expect(described_class.where(src_prefix: 'src-3').count).to eq(64)
        expect(described_class.where(src_prefix: 'src-4').count).to eq(64)
        expect(described_class.count).to eq(128)
      end
    end

    context 'when update not a matching-conditions attribute' do
      let(:attributes) do
        {
          src_rewrite_rule: 'new-src-rewrite-rule'
        }
      end

      it 'each new copy has this attribute' do
        subject
        expect(described_class.where(src_rewrite_rule: attributes[:src_rewrite_rule]).count).to eq(128)
        expect(described_class.count).to eq(128)
      end
    end

    context 'when error happens on update' do
      let(:attributes) do
        {
          src_rewrite_rule: 'new-src-rewrite-rule'
        }
      end

      before do
        expect_any_instance_of(CustomersAuth)
          .to receive(:create_shadow_copy)
                .and_raise(ActiveRecord::StatementInvalid, 'null value in column "customers_auth_id" violates not-null constraint')
      end

      it 'rollback all' do
        subject rescue nil
        expect(described_class.where(src_rewrite_rule: old_src_rewrite_rule).count).to eq(128)
        expect(described_class.count).to eq(128)
        expect(record.reload).to have_attributes(src_rewrite_rule: old_src_rewrite_rule)
      end
    end

  end


  describe '#destroy' do

    before do
      @other_record = create(:customers_auth)
      @record = create(:customers_auth,
                       ip: ['127.0.0.1', '192.168.0.1'],
                       src_prefix: ['src-1', 'src-2'],
                       dst_prefix: ['dst-1', 'dst-2'],
                       uri_domain: ['uri-1', 'uri-2'],
                       from_domain: ['from-1', 'from-2'],
                       to_domain: ['to-1', 'to-2'],
                       x_yeti_auth: ['x-1', 'x-2'])
    end

    subject do
      @record.destroy
    end

    it 'destorys original record' do
      expect { subject }.to change { CustomersAuth.where(id: @record.id).count }.by(-1)
    end

    it 'destroys only related copies' do
      expect { subject }.to change { described_class.count }.from(129).to(1)
      expect(described_class.take).to have_attributes(
        customers_auth_id: @other_record.id
      )
    end

  end


  describe '.column_names' do
    subject do
      described_class.column_names - ['customers_auth_id']
    end

    let(:customers_auth_column_names) do
      CustomersAuth.column_names
    end

    it 'columns should match with original CustomersAuth model' do
      expect(subject).to match_array(customers_auth_column_names)
    end
  end

end
