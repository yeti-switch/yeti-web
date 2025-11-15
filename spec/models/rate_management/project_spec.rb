# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.projects
#
#  id                           :integer(4)       not null, primary key
#  acd_limit                    :float(24)        default(0.0)
#  asr_limit                    :float(24)        default(0.0)
#  capacity                     :integer(2)
#  dst_number_max_length        :integer(2)       default(100), not null
#  dst_number_min_length        :integer(2)       default(0), not null
#  dst_rewrite_result           :string
#  dst_rewrite_rule             :string
#  enabled                      :boolean          default(TRUE), not null
#  exclusive_route              :boolean          default(FALSE), not null
#  force_hit_rate               :float
#  initial_interval             :integer(4)       default(1)
#  keep_applied_pricelists_days :integer(2)       default(30), not null
#  lcr_rate_multiplier          :decimal(, )      default(1.0)
#  name                         :string           not null
#  next_interval                :integer(4)       default(1)
#  priority                     :integer(4)       default(100), not null
#  reverse_billing              :boolean          default(FALSE)
#  routing_tag_ids              :integer(2)       default([]), not null, is an Array
#  short_calls_limit            :float(24)        default(1.0), not null
#  src_name_rewrite_result      :string
#  src_name_rewrite_rule        :string
#  src_rewrite_result           :string
#  src_rewrite_rule             :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  account_id                   :integer(4)       not null
#  gateway_group_id             :integer(4)
#  gateway_id                   :integer(4)
#  routeset_discriminator_id    :integer(2)       not null
#  routing_group_id             :integer(4)       not null
#  routing_tag_mode_id          :integer(2)       default(0)
#  vendor_id                    :integer(4)       not null
#
# Indexes
#
#  index_ratemanagement.projects_on_account_id                 (account_id)
#  index_ratemanagement.projects_on_gateway_group_id           (gateway_group_id)
#  index_ratemanagement.projects_on_gateway_id                 (gateway_id)
#  index_ratemanagement.projects_on_name                       (name) UNIQUE
#  index_ratemanagement.projects_on_routeset_discriminator_id  (routeset_discriminator_id)
#  index_ratemanagement.projects_on_routing_group_id           (routing_group_id)
#  index_ratemanagement.projects_on_routing_tag_mode_id        (routing_tag_mode_id)
#  index_ratemanagement.projects_on_vendor_id                  (vendor_id)
#
# Foreign Keys
#
#  fk_rails_2016c4d0a1  (routing_group_id => routing_groups.id)
#  fk_rails_9da44a0caf  (gateway_group_id => gateway_groups.id)
#  fk_rails_ab15e0e646  (gateway_id => gateways.id)
#  fk_rails_bba2bcfb14  (account_id => accounts.id)
#  fk_rails_ca9d46244c  (routeset_discriminator_id => routeset_discriminators.id)
#  fk_rails_ce692652ea  (vendor_id => contractors.id)
#
RSpec.describe RateManagement::Project do
  describe 'validations' do
    let(:vendor) { FactoryBot.create(:vendor) }
    let(:account) { FactoryBot.create(:account, contractor: vendor) }
    let(:routing_group) { FactoryBot.create(:routing_group) }
    let(:routeset_discriminator) { FactoryBot.create(:routeset_discriminator) }
    let(:gateway) { FactoryBot.create(:gateway, contractor: vendor) }

    let(:project_attrs) do
      {
        name: 'test',
        vendor: vendor,
        account: account,
        routing_group: routing_group,
        routeset_discriminator: routeset_discriminator,
        gateway: gateway
      }
    end

    subject do
      described_class.create(**project_attrs)
    end

    it { is_expected.to validate_presence_of(:dst_number_max_length) }
    it { is_expected.to validate_presence_of(:dst_number_min_length) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:short_calls_limit) }
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:routeset_discriminator).required }
    it { is_expected.to belong_to(:routing_group).required }
    it { is_expected.to belong_to(:vendor).required }
    it { is_expected.to validate_presence_of(:keep_applied_pricelists_days) }
    it { is_expected.to validate_numericality_of(:keep_applied_pricelists_days).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:keep_applied_pricelists_days).is_less_than_or_equal_to(365) }

    it { is_expected.to validate_uniqueness_of :name }

    it { is_expected.to validate_numericality_of(:initial_interval).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:next_interval).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:acd_limit).is_greater_than_or_equal_to(0.00) }
    it { is_expected.to validate_numericality_of(:acd_limit).allow_nil }
    it { is_expected.to validate_numericality_of(:asr_limit).is_greater_than_or_equal_to(0.00) }
    it { is_expected.to validate_numericality_of(:asr_limit).is_less_than_or_equal_to(1.00) }
    it { is_expected.to validate_numericality_of(:asr_limit).allow_nil }
    it { is_expected.to validate_numericality_of(:short_calls_limit).is_greater_than_or_equal_to(0.00) }
    it { is_expected.to validate_numericality_of(:short_calls_limit).is_less_than_or_equal_to(1.00) }
    it { is_expected.to validate_numericality_of(:force_hit_rate).is_greater_than_or_equal_to(0.00) }
    it { is_expected.to validate_numericality_of(:force_hit_rate).is_less_than_or_equal_to(1.00) }
    it { is_expected.to validate_numericality_of(:force_hit_rate).allow_nil }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT) }
    it { is_expected.to validate_numericality_of(:capacity).allow_nil }
    it { is_expected.to validate_numericality_of(:capacity).only_integer }
    it { is_expected.to validate_numericality_of(:dst_number_min_length).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:dst_number_min_length).is_less_than_or_equal_to(100) }
    it { is_expected.to validate_numericality_of(:dst_number_min_length).only_integer }
    it { is_expected.to validate_numericality_of(:dst_number_max_length).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:dst_number_max_length).is_less_than_or_equal_to(100) }
    it { is_expected.to validate_numericality_of(:dst_number_max_length).only_integer }

    context 'when contactor is not a vendor' do
      let(:vendor) { FactoryBot.create(:customer) }

      include_examples :does_not_create_record, errors: {
        vendor: ['Is not vendor']
      }
    end

    context 'when account owner is another vendor' do
      let(:another_vendor) { FactoryBot.create(:vendor) }
      let(:account) { FactoryBot.create(:account, contractor: another_vendor) }

      include_examples :does_not_create_record, errors: {
        account: ['must be owned by selected vendor']
      }
    end

    context 'with gateway' do
      let(:gateway) { FactoryBot.create(:gateway, contractor: vendor, is_shared: true) }
      let(:project_attrs) { super().merge(gateway: gateway) }

      include_examples :creates_record do
        let(:expected_record_attrs) { project_attrs }
      end

      context 'when gateway owner is another vendor' do
        let(:another_vendor) { FactoryBot.create(:vendor) }
        let(:gateway) { FactoryBot.create(:gateway, contractor: another_vendor) }

        include_examples :does_not_create_record, errors: {
          gateway: ['must be owned by selected vendor or be shared']
        }
      end

      context 'when gateway owner is allow termination' do
        let(:gateway) { FactoryBot.create(:gateway, contractor: vendor, allow_termination: false) }

        include_examples :does_not_create_record, errors: {
          gateway: ['must be allowed for termination']
        }
      end
    end

    context 'with gateway group' do
      let(:gateway_group) { FactoryBot.create(:gateway_group, vendor: vendor) }
      let(:project_attrs) { super().merge(gateway_group: gateway_group, gateway: nil) }

      include_examples :creates_record do
        let(:expected_record_attrs) { project_attrs }
      end

      context 'when gateway owner is another vendor' do
        let(:another_vendor) { FactoryBot.create(:vendor) }
        let(:gateway_group) { FactoryBot.create(:gateway_group, vendor: another_vendor) }

        include_examples :does_not_create_record, errors: {
          gateway_group: ['must be owned by selected vendor']
        }
      end
    end

    context 'with both gateway and gateway group' do
      let(:gateway) { FactoryBot.create(:gateway, contractor: vendor, is_shared: true) }
      let(:gateway_group) { FactoryBot.create(:gateway_group, vendor: vendor) }
      let(:project_attrs) { super().merge(gateway: gateway, gateway_group: gateway_group) }

      include_examples :does_not_create_record, errors: {
        base: ["both gateway and gateway_group can't be set in a same time"]
      }
    end

    context 'when priority > max int 4 bytes' do
      let(:project_attrs) { super().merge(priority: 2_147_483_648) }

      include_examples :does_not_create_record, errors: {
        priority: ['must be less than or equal to 2147483647']
      }
    end

    context 'when priority < min int 4 bytes' do
      let(:project_attrs) { super().merge(priority: -2_147_483_648) }

      include_examples :does_not_create_record, errors: {
        priority: ['must be greater than or equal to -2147483647']
      }
    end

    context 'with only default attributes' do
      let(:project_attrs) { {} }

      include_examples :does_not_create_record, errors: {
        routing_group: ['must exist'],
        account: ['must exist'],
        vendor: ['must exist'],
        routeset_discriminator: ['must exist'],
        name: ["can't be blank"],
        base: ['specify a gateway_group or a gateway']
      }
    end

    context 'with nil attributes' do
      let(:project_attrs) do
        {
          acd_limit: nil,
          asr_limit: nil,
          dst_number_max_length: nil,
          dst_number_min_length: nil,
          enabled: nil,
          exclusive_route: nil,
          initial_interval: nil,
          keep_applied_pricelists_days: nil,
          lcr_rate_multiplier: nil,
          next_interval: nil,
          priority: nil,
          reverse_billing: nil,
          short_calls_limit: nil,
          routing_tag_mode_id: nil
        }
      end

      include_examples :does_not_create_record, errors: {
        routing_group: ['must exist'],
        account: ['must exist'],
        vendor: ['must exist'],
        routeset_discriminator: ['must exist'],
        dst_number_max_length: ["can't be blank"],
        dst_number_min_length: ["can't be blank"],
        name: ["can't be blank"],
        short_calls_limit: ["can't be blank"],
        keep_applied_pricelists_days: ["can't be blank"],
        enabled: ['is not included in the list'],
        exclusive_route: ['is not included in the list'],
        priority: ["can't be blank"],
        base: ['specify a gateway_group or a gateway']
      }
    end
  end
end
