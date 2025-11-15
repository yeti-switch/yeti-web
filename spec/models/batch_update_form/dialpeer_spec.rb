# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Dialpeer do
  let!(:_dialpeers) { FactoryBot.create_list :dialpeer, 3 }
  let!(:vendor_other) { FactoryBot.create :vendor }
  let!(:gateway_shared) { FactoryBot.create :gateway, is_shared: true }
  let!(:gateway) { FactoryBot.create :gateway }
  let!(:vendor_main) { FactoryBot.create :vendor }
  let!(:account_vendors) { FactoryBot.create :account, contractor: vendor_main }
  let!(:gateway_not_allow_termination) { create :gateway, allow_termination: false, contractor: vendor_main }
  let!(:gateway_group) { FactoryBot.create :gateway_group }
  let!(:gateway_vendors) { FactoryBot.create :gateway, contractor: vendor_main }
  let!(:gateway_group_vendors) { FactoryBot.create :gateway_group, vendor: vendor_main }
  let!(:account) { FactoryBot.create :account }
  let(:pg_max_smallint) { ApplicationRecord::PG_MAX_SMALLINT }
  let(:assign_params) do
    {
      enabled: 'true',
      prefix: 'string',
      dst_number_min_length: '10',
      dst_number_max_length: '20',
      routing_tag_mode_id: Routing::RoutingTagMode::MODE_AND.to_s,
      routing_group_id: Routing::RoutingGroup.last!.id.to_s,
      priority: '3',
      force_hit_rate: '0.5',
      exclusive_route: true,
      initial_interval: '12',
      initial_rate: '12',
      next_interval: '12',
      next_rate: '12',
      connect_fee: '12',
      lcr_rate_multiplier: '12',
      gateway_id: gateway_vendors.id.to_s,
      gateway_group_id: gateway_group_vendors.id.to_s,
      vendor_id: vendor_main.id.to_s,
      account_id: account_vendors.id.to_s,
      routeset_discriminator_id: Routing::RoutesetDiscriminator.last!.id.to_s,
      valid_from: '2020-01-10',
      valid_till: '2020-01-20',
      asr_limit: '0.9',
      acd_limit: '0.9',
      short_calls_limit: '0.9',
      capacity: '12',
      src_name_rewrite_rule: '12',
      src_name_rewrite_result: '12',
      src_rewrite_rule: '12',
      src_rewrite_result: '12',
      dst_rewrite_rule: '12',
      dst_rewrite_result: '12'
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  describe 'validation' do
    context 'fill all fields with valid values' do
      it 'should be valid' do expect(subject).to be_valid end

      # presence validation
      it { is_expected.to_not allow_value('', ' ').for :dst_number_min_length }
      it { is_expected.to_not allow_value('', ' ').for :dst_number_max_length }
      it { is_expected.to_not allow_value('', ' ').for :initial_interval }
      it { is_expected.to_not allow_value('', ' ').for :initial_rate }
      it { is_expected.to_not allow_value('', ' ').for :next_interval }
      it { is_expected.to_not allow_value('', ' ').for :next_rate }
      it { is_expected.to_not allow_value('', ' ').for :connect_fee }
      it { is_expected.to_not allow_value('', ' ').for :acd_limit }
      it { is_expected.to_not allow_value('', ' ').for :asr_limit }
      it { is_expected.to_not allow_value('', ' ').for :prefix }
      it { is_expected.to_not allow_value('', ' ').for :priority }
      it { is_expected.to_not allow_value('', ' ').for :valid_from }
      it { is_expected.to_not allow_value('', ' ').for :valid_till }
      it { is_expected.to_not allow_value('', ' ').for :short_calls_limit }
      it { is_expected.to_not allow_value('', ' ').for :lcr_rate_multiplier }

      # other validations
      context 'when :gateway_id is not allowed for termination' do
        let(:assign_params) do
          {
            account_id: account_vendors.id.to_s,
            gateway_id: gateway_not_allow_termination.id.to_s,
            gateway_group_id: gateway_group_vendors.id.to_s,
            vendor_id: vendor_main.id.to_s
          }
        end

        it 'should have error: must be allowed for termination' do
          subject
          expect(subject.errors[:gateway_id]).to contain_exactly I18n.t 'activerecord.errors.models.dialpeer.attributes.gateway.allow_termination'
          expect(subject.errors.size).to eq 1
        end
      end

      context 'when :account_id, :gateway_id and :gateway_group_id is not owned by selected :vendor_id' do
        let(:assign_params) do
          {
            account_id: account_vendors.id.to_s,
            gateway_id: gateway_vendors.id.to_s,
            gateway_group_id: gateway_group_vendors.id.to_s,
            vendor_id: vendor_other.id.to_s
          }
        end

        it 'should have errors' do
          subject
          expect(subject.errors[:gateway_id]).to contain_exactly I18n.t('activerecord.errors.models.dialpeer.attributes.gateway.wrong_owner')
          expect(subject.errors[:gateway_group_id]).to contain_exactly I18n.t('activerecord.errors.models.dialpeer.attributes.gateway_group.wrong_owner')
          expect(subject.errors[:account_id]).to contain_exactly I18n.t('activerecord.errors.models.dialpeer.attributes.account.wrong_owner')
          expect(subject.errors.size).to eq 3
        end
      end

      context 'when selected :gateway_id than is shared' do
        let(:assign_params) { { gateway_id: gateway_shared.id.to_s } }

        it 'should pass validations' do expect(subject).to be_valid end
      end

      context 'when :account_id change value without :vendor_id' do
        let(:assign_params) { { account_id: account.id.to_s } }

        it 'should have error: must be changed together' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Account must be changed together with Vendor'
        end
      end

      context 'when :vendor_id change value without :account_id' do
        let(:assign_params) { { vendor_id: vendor_other.id.to_s } }

        it 'should have error: must be changed together' do
          subject
          errors_for_vendor = :vendor_id, [
            'must be changed together with Account',
            'must be changed together with Gateway',
            'must be changed together with Gateway group'
          ]
          expect(subject.errors.messages).to contain_exactly errors_for_vendor
        end
      end

      context 'when gateway_id change value without vendor_id' do
        let(:assign_params) { { gateway_id: gateway.id.to_s } }

        it 'should have error:' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Gateway must be changed together with Vendor'
        end
      end

      context 'when :gateway_id change value and selected gateway are be shared' do
        let(:assign_params) { { gateway_id: gateway_shared.id.to_s } }

        it 'should pass validations' do expect(subject).to be_valid end
      end

      context 'when :gateway_group_id change value without :vendor_id' do
        let(:assign_params) { { gateway_group_id: gateway_group.id.to_s } }

        it 'should have error: must be changed together with Vendor' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Gateway group must be changed together with Vendor'
        end
      end

      context 'when change account, gateway, vendor and gateway_group with valid values' do
        let(:assign_params) do
          {
            account_id: account_vendors.id,
            gateway_id: gateway_vendors.id,
            gateway_group_id: gateway_group_vendors.id,
            vendor_id: vendor_main.id
          }
        end

        it 'should pass validations' do expect(subject).to be_valid end
      end

      context 'when :valid_from change value without :valid_till' do
        let(:assign_params) { { valid_from: '2020-02-02' } }

        it 'should have error: must be changed together with Valid till' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Valid from must be changed together with Valid till'
        end
      end

      context 'when :valid_from is empty' do
        let(:assign_params) { { valid_from: '' } }

        it "should error: can't be blank and must be changed together" do
          subject
          expect(subject.errors.to_a).to contain_exactly "Valid from can't be blank", 'Valid from must be changed together with Valid till'
        end
      end

      context 'when :valid_from is empty and :valid_till is filled' do
        let(:assign_params) { { valid_from: '', valid_till: '2020-02-02' } }

        it "should have error: can't be blank" do
          subject
          expect(subject.errors.to_a).to contain_exactly "Valid from can't be blank"
        end
      end

      context 'when :valid_till change value without :valid_from' do
        let(:assign_params) { { valid_till: '2020-02-02' } }

        it 'should have error: must be changed together with Valid till' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Valid till must be changed together with Valid from'
        end
      end

      context 'when change :valid_till and :valid_from with equal values' do
        let(:assign_params) { { valid_from: '2020-02-02', valid_till: '2020-02-02' } }

        it 'should pass validations' do expect(subject).to be_valid end
      end

      context 'when :valid_till is before than :valid_from' do
        let(:assign_params) { { valid_from: '2020-05-05', valid_till: '2020-01-01' } }

        it 'should have error:' do
          subject
          expect(subject.errors.to_a).to contain_exactly "Valid from must be before or equal to #{assign_params[:valid_till]}"
        end
      end

      context 'when :dst_number_min_length change value without :dst_number_max_length' do
        let(:assign_params) { { dst_number_min_length: '12' } }

        it 'should have error: must be changed together with Valid till' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Dst number min length must be changed together with Dst number max length'
        end
      end

      context 'when :dst_number_max_length change value without :dst_number_min_length' do
        let(:assign_params) { { dst_number_max_length: '10' } }

        it 'should have error: must be changed together with Valid till' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Dst number max length must be changed together with Dst number min length'
        end
      end

      context 'when change :dst_number_max_length and :dst_number_min_length with equal values' do
        let(:assign_params) { { dst_number_max_length: '10', dst_number_min_length: '10' } }

        it 'should pass validations' do expect(subject).to be_valid end
      end

      context 'when :dst_number_min_length field less than :dst_number_max_length' do
        let(:assign_params) { { dst_number_min_length: '100', dst_number_max_length: '1' } }

        it 'should have error:' do
          subject
          expect(subject.errors.to_a).to contain_exactly "Dst number min length must be less than or equal to #{assign_params[:dst_number_max_length]}"
        end
      end

      context 'when :dst_number_max_length field is a string, and :dst_number_min_length filled with valid value' do
        let(:assign_params) { { dst_number_min_length: '100', dst_number_max_length: 'string' } }

        it 'should have error:' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Dst number max length is not a number'
        end
      end

      context 'when :dst_number_min_length field is a string, and :dst_number_max_length filled with valid value' do
        let(:assign_params) { { dst_number_min_length: 'string', dst_number_max_length: '10' } }

        it 'should have error:' do
          subject
          expect(subject.errors.to_a).to contain_exactly 'Dst number min length is not a number'
        end
      end

      context 'when change :exclusive_route field into true' do
        let(:assign_params) { { exclusive_route: 'true' } }

        it 'should pass validations' do expect(subject).to be_valid end
      end

      # force_hit_rate
      it { is_expected.to allow_value('0', '1', '0.1', '0.5', '0.9', '1.0').for :force_hit_rate }
      it { is_expected.to allow_value('').for :force_hit_rate }
      it { is_expected.to_not allow_value('1.1').for :force_hit_rate }

      # lcr_rate_multiplier
      it { is_expected.to allow_value('0.1', '1', '10000').for :lcr_rate_multiplier }
      it { is_expected.to_not allow_value('string').for :lcr_rate_multiplier }

      # src_name_rewrite_rule
      it { is_expected.to allow_value('', 'string').for :src_name_rewrite_rule }

      # src_rewrite_rule
      it { is_expected.to allow_value('', 'string').for :src_rewrite_rule }

      # src_rewrite_result
      it { is_expected.to allow_value('', 'string').for :src_rewrite_result }

      # dst_rewrite_rule
      it { is_expected.to allow_value('', 'string').for :dst_rewrite_rule }

      # dst_rewrite_result
      it { is_expected.to allow_value('', 'string').for :dst_rewrite_result }

      # numericality
      it { is_expected.to validate_numericality_of(:lcr_rate_multiplier) }
      it { is_expected.to validate_numericality_of(:force_hit_rate).is_greater_than_or_equal_to(0.00) }
      it { is_expected.to validate_numericality_of(:force_hit_rate).is_less_than_or_equal_to(1.00) }
      it { is_expected.to validate_numericality_of(:force_hit_rate).allow_nil }
      it { is_expected.to validate_numericality_of :initial_rate }
      it { is_expected.to validate_numericality_of :next_rate }
      it { is_expected.to validate_numericality_of :connect_fee }
      it { is_expected.to validate_numericality_of :initial_interval }
      it { is_expected.to validate_numericality_of :next_interval }
      it { is_expected.to validate_numericality_of(:priority).only_integer }
      it { is_expected.to validate_numericality_of(:acd_limit).is_greater_than_or_equal_to(0.00) }
      it { is_expected.to validate_numericality_of(:acd_limit).is_less_than_or_equal_to(1.00) }
      it { is_expected.to validate_numericality_of(:asr_limit).is_greater_than_or_equal_to(0.00) }
      it { is_expected.to validate_numericality_of(:asr_limit).is_less_than_or_equal_to(1.00) }
      it { is_expected.to validate_numericality_of(:short_calls_limit).is_greater_than_or_equal_to(0.00) }
      it { is_expected.to validate_numericality_of(:short_calls_limit).is_less_than_or_equal_to(1.00) }
      it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
      it { is_expected.to validate_numericality_of(:capacity).is_less_than_or_equal_to(pg_max_smallint) }
      it { is_expected.to validate_numericality_of(:dst_number_max_length).is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_numericality_of(:dst_number_max_length).is_less_than_or_equal_to(100) }
      it { is_expected.to validate_numericality_of(:dst_number_max_length).only_integer }
      it { is_expected.to validate_numericality_of(:dst_number_min_length).is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_numericality_of :dst_number_min_length }
      it { is_expected.to validate_numericality_of(:dst_number_min_length).only_integer }

      # only integer
      it { is_expected.to_not allow_value(0.5).for :dst_number_min_length }
      it { is_expected.to_not allow_value(0.5).for :dst_number_max_length }
      it { is_expected.to_not allow_value(0.5).for :priority }

      # format validation
      it { is_expected.to_not allow_value('test prefix').for :prefix }
      it { is_expected.to allow_value('test_prefix').for :prefix }
    end
  end
end
