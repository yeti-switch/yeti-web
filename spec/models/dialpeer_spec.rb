# frozen_string_literal: true

# == Schema Information
#
# Table name: dialpeers
#
#  id                        :bigint(8)        not null, primary key
#  acd_limit                 :float            default(0.0), not null
#  asr_limit                 :float            default(0.0), not null
#  capacity                  :integer(2)
#  connect_fee               :decimal(, )      default(0.0), not null
#  dst_number_max_length     :integer(2)       default(100), not null
#  dst_number_min_length     :integer(2)       default(0), not null
#  dst_rewrite_result        :string
#  dst_rewrite_rule          :string
#  enabled                   :boolean          not null
#  exclusive_route           :boolean          default(FALSE), not null
#  force_hit_rate            :float
#  initial_interval          :integer(4)       default(1), not null
#  initial_rate              :decimal(, )      not null
#  lcr_rate_multiplier       :decimal(, )      default(1.0), not null
#  locked                    :boolean          default(FALSE), not null
#  next_interval             :integer(4)       default(1), not null
#  next_rate                 :decimal(, )      not null
#  prefix                    :string           not null
#  priority                  :integer(4)       default(100), not null
#  reverse_billing           :boolean          default(FALSE), not null
#  routing_tag_ids           :integer(2)       default([]), not null, is an Array
#  short_calls_limit         :float            default(1.0), not null
#  src_name_rewrite_result   :string
#  src_name_rewrite_rule     :string
#  src_rewrite_result        :string
#  src_rewrite_rule          :string
#  valid_from                :datetime         not null
#  valid_till                :datetime         not null
#  created_at                :datetime         not null
#  account_id                :integer(4)       not null
#  current_rate_id           :bigint(8)
#  external_id               :bigint(8)
#  gateway_group_id          :integer(4)
#  gateway_id                :integer(4)
#  network_prefix_id         :integer(4)
#  routeset_discriminator_id :integer(2)       default(1), not null
#  routing_group_id          :integer(4)       not null
#  routing_tag_mode_id       :integer(2)       default(0), not null
#  vendor_id                 :integer(4)       not null
#
# Indexes
#
#  dialpeers_external_id_idx                          (external_id)
#  dialpeers_prefix_range_idx                         (((prefix)::prefix_range)) USING gist
#  dialpeers_prefix_range_valid_from_valid_till_idx   (((prefix)::prefix_range), valid_from, valid_till) WHERE enabled USING gist
#  dialpeers_prefix_range_valid_from_valid_till_idx1  (((prefix)::prefix_range), valid_from, valid_till) WHERE (enabled AND (NOT locked)) USING gist
#
# Foreign Keys
#
#  dialpeers_account_id_fkey                 (account_id => accounts.id)
#  dialpeers_gateway_group_id_fkey           (gateway_group_id => gateway_groups.id)
#  dialpeers_gateway_id_fkey                 (gateway_id => gateways.id)
#  dialpeers_routeset_discriminator_id_fkey  (routeset_discriminator_id => routeset_discriminators.id)
#  dialpeers_routing_group_id_fkey           (routing_group_id => routing_groups.id)
#  dialpeers_routing_tag_mode_id_fkey        (routing_tag_mode_id => routing_tag_modes.id)
#  dialpeers_vendor_id_fkey                  (vendor_id => contractors.id)
#

RSpec.describe Dialpeer, type: :model do
  describe 'validations' do
    it do
      is_expected.to validate_numericality_of(:capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    end

    describe '.errors' do
      let(:record) { described_class.new(attributes) }

      before { record.validate }
      subject do
        record.errors.to_h
      end

      context 'without Gateway' do
        let(:attributes) {}

        include_examples :validation_error_on_field, :base, 'Specify a gateway_group or a gateway'
        include_examples :validation_no_error_on_field, :gateway
      end

      context 'with Gateway_id 0' do
        let(:attributes) { { gateway_id: 0 } }

        include_examples :validation_error_on_field, :base, 'Specify a gateway_group or a gateway'
      end

      context 'with Gateway_group_id 0' do
        let(:attributes) { { gateway_group_id: 0 } }

        include_examples :validation_error_on_field, :base, 'Specify a gateway_group or a gateway'
      end

      context 'with Gateway' do
        let(:attributes) { { gateway: g, vendor_id: vendor.id, gateway_id: g.id } }
        let(:vendor) { g.contractor }
        let(:g) { create(:gateway, g_attr) }
        let(:g_attr) do
          {}
        end

        context 'not allow_termination' do
          let(:g_attr) { { allow_termination: false } }

          include_examples :validation_error_on_field, :gateway, 'must be allowed for termination'
        end

        context 'different vendor' do
          let(:vendor) { create(:vendor) }
          let(:g_attr) { { allow_termination: true } }

          include_examples :validation_error_on_field, :gateway, 'must be owned by selected vendor or be shared'
        end

        context 'different vendor, gateway is shared' do
          let(:vendor) { create(:vendor) }
          let(:g_attr) { { allow_termination: true, is_shared: true } }

          include_examples :validation_no_error_on_field, :gateway
        end
      end
    end
  end

  context 'validate routing_tag_ids' do
    include_examples :test_model_with_routing_tag_ids
  end
end
