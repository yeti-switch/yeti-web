# == Schema Information
#
# Table name: class4.customers_auth
#
#  id                               :integer          not null, primary key
#  customer_id                      :integer          not null
#  rateplan_id                      :integer          not null
#  enabled                          :boolean          default(TRUE), not null
#  account_id                       :integer
#  gateway_id                       :integer          not null
#  src_rewrite_rule                 :string
#  src_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  dst_rewrite_result               :string
#  name                             :string           not null
#  dump_level_id                    :integer          default(0), not null
#  capacity                         :integer
#  pop_id                           :integer
#  src_name_rewrite_rule            :string
#  src_name_rewrite_result          :string
#  diversion_policy_id              :integer          default(1), not null
#  diversion_rewrite_rule           :string
#  diversion_rewrite_result         :string
#  dst_numberlist_id                :integer
#  src_numberlist_id                :integer
#  routing_plan_id                  :integer          not null
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  radius_auth_profile_id           :integer
#  enable_audio_recording           :boolean          default(FALSE), not null
#  src_number_radius_rewrite_rule   :string
#  src_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_number_radius_rewrite_result :string
#  radius_accounting_profile_id     :integer
#  transport_protocol_id            :integer
#  dst_number_max_length            :integer          default(100), not null
#  check_account_balance            :boolean          default(TRUE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  tag_action_id                    :integer
#  tag_action_value                 :integer          default([]), not null, is an Array
#  dst_number_min_length            :integer          default(0), not null
#  ip                               :inet             default(["\"127.0.0.0/8\""]), is an Array
#  src_prefix                       :string           default(["\"\""]), is an Array
#  dst_prefix                       :string           default(["\"\""]), is an Array
#  uri_domain                       :string           default([]), is an Array
#  from_domain                      :string           default([]), is an Array
#  to_domain                        :string           default([]), is an Array
#  x_yeti_auth                      :string           default([]), is an Array
#  external_id                      :integer
#

require 'spec_helper'

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
      should validate_numericality_of(:capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
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
