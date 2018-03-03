# == Schema Information
#
# Table name: dialpeers
#
#  id                      :integer          not null, primary key
#  enabled                 :boolean          not null
#  prefix                  :string           not null
#  src_rewrite_rule        :string
#  dst_rewrite_rule        :string
#  acd_limit               :float            default(0.0), not null
#  asr_limit               :float            default(0.0), not null
#  gateway_id              :integer
#  routing_group_id        :integer          not null
#  next_rate               :decimal(, )      not null
#  connect_fee             :decimal(, )      default(0.0), not null
#  vendor_id               :integer          not null
#  account_id              :integer          not null
#  src_rewrite_result      :string
#  dst_rewrite_result      :string
#  locked                  :boolean          default(FALSE), not null
#  priority                :integer          default(100), not null
#  capacity                :integer
#  lcr_rate_multiplier     :decimal(, )      default(1.0), not null
#  initial_rate            :decimal(, )      not null
#  initial_interval        :integer          default(1), not null
#  next_interval           :integer          default(1), not null
#  valid_from              :datetime         not null
#  valid_till              :datetime         not null
#  gateway_group_id        :integer
#  force_hit_rate          :float
#  network_prefix_id       :integer
#  created_at              :datetime         not null
#  short_calls_limit       :float            default(1.0), not null
#  current_rate_id         :integer
#  external_id             :integer
#  src_name_rewrite_rule   :string
#  src_name_rewrite_result :string
#  exclusive_route         :boolean          default(FALSE), not null
#  routing_tag_id          :integer
#  dst_number_min_length   :integer          default(0), not null
#  dst_number_max_length   :integer          default(100), not null
#  reverse_billing         :boolean          default(FALSE), not null
#  routing_tag_ids         :integer          default([]), not null, is an Array
#

require 'spec_helper'

describe Dialpeer, type: :model do

  describe 'validations' do

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

  context 'validate routing_tag_ids' do
    include_examples :test_model_with_routing_tag_ids
  end

end

