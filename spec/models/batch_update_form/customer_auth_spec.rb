# frozen_string_literal: true

RSpec.describe BatchUpdateForm::CustomersAuth do
  let!(:routing_plan) { FactoryBot.create :routing_plan }
  let!(:lua_script) { FactoryBot.create :lua_script }
  let!(:rateplan) { FactoryBot.create :rateplan }
  let!(:dump_level_id) { CustomersAuth::DUMP_LEVEL_CAPTURE_RTP }
  let!(:numberlist) { FactoryBot.create :numberlist }
  let!(:protocol) { Equipment::TransportProtocol.last! }
  let!(:assign_params) do
    {
      enabled: 'true',
      reject_calls: 'true',
      transport_protocol_id: protocol.id.to_s,
      src_number_min_length: '2',
      src_number_max_length: '20',
      dst_number_min_length: '5',
      dst_number_max_length: '50',
      dst_numberlist_id: numberlist.id.to_s,
      src_numberlist_id: numberlist.id.to_s,
      dump_level_id: dump_level_id,
      rateplan_id: rateplan.id.to_s,
      routing_plan_id: routing_plan.id.to_s,
      lua_script_id: lua_script.id.to_s
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    it 'should be valid' do expect(subject).to be_valid end

    # presence
    it { is_expected.to_not allow_value('', ' ').for :src_number_min_length }
    it { is_expected.to_not allow_value('', ' ').for :src_number_max_length }
    it { is_expected.to_not allow_value('', ' ').for :dst_number_min_length }
    it { is_expected.to_not allow_value('', ' ').for :dst_number_max_length }

    # numericality
    it { is_expected.to validate_numericality_of(:src_number_max_length) }
    it { is_expected.to validate_numericality_of(:src_number_max_length).is_less_than_or_equal_to 100 }
    it { is_expected.to validate_numericality_of(:src_number_max_length).only_integer }

    it { is_expected.to validate_numericality_of(:src_number_min_length).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:src_number_min_length).is_less_than_or_equal_to 100 }
    it { is_expected.to validate_numericality_of(:src_number_min_length).only_integer }

    it { is_expected.to validate_numericality_of(:dst_number_max_length) }
    it { is_expected.to validate_numericality_of(:dst_number_max_length).is_less_than_or_equal_to 100 }
    it { is_expected.to validate_numericality_of(:dst_number_max_length).only_integer }

    it { is_expected.to validate_numericality_of(:dst_number_min_length).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_numericality_of(:dst_number_min_length).is_less_than_or_equal_to 100 }
    it { is_expected.to validate_numericality_of(:dst_number_min_length).only_integer }

    # other validation
    context 'when :src_number_min_length change value without :src_number_max_length' do
      let(:assign_params) { { src_number_min_length: '12' } }

      it 'should have error: must be changed together' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Src number min length must be changed together with Src number max length'
      end
    end

    context 'when :src_number_max_length change value without :src_number_min_length' do
      let(:assign_params) { { src_number_max_length: '12' } }

      it 'should have error: must be changed together' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Src number max length must be changed together with Src number min length'
      end
    end

    context 'when :dst_number_min_length change value without :dst_number_max_length' do
      let(:assign_params) { { dst_number_min_length: '12' } }

      it 'should have error: must be changed together' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Dst number min length must be changed together with Dst number max length'
      end
    end

    context 'when :dst_number_max_length change value without :dst_number_min_length' do
      let(:assign_params) { { dst_number_max_length: '12' } }

      it 'should have error: must be changed together' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Dst number max length must be changed together with Dst number min length'
      end
    end

    context 'when :src_number_min_length filled and :src_number_max_length is empty' do
      let(:assign_params) { { src_number_min_length: '12', src_number_max_length: '' } }

      it "should have error: can't be blank" do
        subject
        expect(subject.errors.to_a).to contain_exactly "Src number max length can't be blank"
      end
    end

    context 'when :src_number_min_length filled and :src_number_max_length is string' do
      let(:assign_params) { { src_number_min_length: '12', src_number_max_length: 'string' } }

      it 'should have error: is not a number' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Src number max length is not a number'
      end
    end

    context 'when :dst_number_min_length filled and :dst_number_max_length is empty' do
      let(:assign_params) { { dst_number_min_length: '12', dst_number_max_length: '' } }

      it "should have error: can't be blank" do
        subject
        expect(subject.errors.to_a).to contain_exactly "Dst number max length can't be blank"
      end
    end

    context 'when :dst_number_min_length filled and :dst_number_max_length is string' do
      let(:assign_params) { { dst_number_min_length: '12', dst_number_max_length: 'string' } }

      it 'should have error: is not a number' do
        subject
        expect(subject.errors.to_a).to contain_exactly 'Dst number max length is not a number'
      end
    end

    context 'when :dst_number_min_length is not greater than :dst_number_max_length' do
      let(:assign_params) { { dst_number_min_length: '100', dst_number_max_length: '1' } }

      it 'should have error: must be greater than or equal to' do
        subject
        expect(subject.errors.to_a).to contain_exactly "Dst number max length must be greater than or equal to #{assign_params[:dst_number_min_length]}"
      end
    end

    context 'when :dst_number_min_length is not greater than :dst_number_max_length' do
      let(:assign_params) { { src_number_min_length: '100', src_number_max_length: '1' } }

      it 'should have error: must be greater than or equal to' do
        subject
        expect(subject.errors.to_a).to contain_exactly "Src number max length must be greater than or equal to #{assign_params[:src_number_min_length]}"
      end
    end
  end
end
