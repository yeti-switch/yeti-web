# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.customers_auth
#
#  id                               :integer(4)       not null, primary key
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  capacity                         :integer(2)
#  check_account_balance            :boolean          default(TRUE), not null
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dst_number_max_length            :integer(2)       default(100), not null
#  dst_number_min_length            :integer(2)       default(0), not null
#  dst_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_prefix                       :string           default(["\"\""]), is an Array
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  enable_audio_recording           :boolean          default(FALSE), not null
#  enabled                          :boolean          default(TRUE), not null
#  from_domain                      :string           default([]), is an Array
#  ip                               :inet             default(["\"127.0.0.0/8\""]), is an Array
#  name                             :string           not null
#  reject_calls                     :boolean          default(FALSE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_number_max_length            :integer(2)       default(100), not null
#  src_number_min_length            :integer(2)       default(0), not null
#  src_number_radius_rewrite_result :string
#  src_number_radius_rewrite_rule   :string
#  src_prefix                       :string           default(["\"\""]), is an Array
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  tag_action_value                 :integer(2)       default([]), not null, is an Array
#  to_domain                        :string           default([]), is an Array
#  uri_domain                       :string           default([]), is an Array
#  x_yeti_auth                      :string           default([]), is an Array
#  account_id                       :integer(4)
#  customer_id                      :integer(4)       not null
#  diversion_policy_id              :integer(4)       default(1), not null
#  dst_numberlist_id                :integer(2)
#  dump_level_id                    :integer(4)       default(0), not null
#  external_id                      :bigint(8)
#  gateway_id                       :integer(4)       not null
#  lua_script_id                    :integer(2)
#  pop_id                           :integer(4)
#  radius_accounting_profile_id     :integer(2)
#  radius_auth_profile_id           :integer(2)
#  rateplan_id                      :integer(4)       not null
#  routing_plan_id                  :integer(4)       not null
#  src_numberlist_id                :integer(2)
#  tag_action_id                    :integer(2)
#  transport_protocol_id            :integer(2)
#
# Indexes
#
#  customers_auth_external_id_key  (external_id) UNIQUE
#  customers_auth_name_key         (name) UNIQUE
#
# Foreign Keys
#
#  customers_auth_account_id_fkey                    (account_id => accounts.id)
#  customers_auth_customer_id_fkey                   (customer_id => contractors.id)
#  customers_auth_diversion_policy_id_fkey           (diversion_policy_id => diversion_policy.id)
#  customers_auth_dst_blacklist_id_fkey              (dst_numberlist_id => numberlists.id)
#  customers_auth_dump_level_id_fkey                 (dump_level_id => dump_level.id)
#  customers_auth_gateway_id_fkey                    (gateway_id => gateways.id)
#  customers_auth_lua_script_id_fkey                 (lua_script_id => lua_scripts.id)
#  customers_auth_pop_id_fkey                        (pop_id => pops.id)
#  customers_auth_radius_accounting_profile_id_fkey  (radius_accounting_profile_id => radius_accounting_profiles.id)
#  customers_auth_radius_auth_profile_id_fkey        (radius_auth_profile_id => radius_auth_profiles.id)
#  customers_auth_rateplan_id_fkey                   (rateplan_id => rateplans.id)
#  customers_auth_routing_plan_id_fkey               (routing_plan_id => routing_plans.id)
#  customers_auth_src_blacklist_id_fkey              (src_numberlist_id => numberlists.id)
#  customers_auth_tag_action_id_fkey                 (tag_action_id => tag_actions.id)
#  customers_auth_transport_protocol_id_fkey         (transport_protocol_id => transport_protocols.id)
#

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
