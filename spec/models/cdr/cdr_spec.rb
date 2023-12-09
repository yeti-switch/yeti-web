# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr.cdr
#
#  id                              :bigint(8)        not null, primary key
#  audio_recorded                  :boolean
#  auth_orig_ip                    :inet
#  auth_orig_port                  :integer(4)
#  core_version                    :string
#  customer_acc_vat                :decimal(, )
#  customer_account_check_balance  :boolean
#  customer_auth_external_type     :string
#  customer_auth_name              :string
#  customer_duration               :integer(4)
#  customer_price                  :decimal(, )
#  customer_price_no_vat           :decimal(, )
#  destination_fee                 :decimal(, )
#  destination_initial_interval    :integer(4)
#  destination_initial_rate        :decimal(, )
#  destination_next_interval       :integer(4)
#  destination_next_rate           :decimal(, )
#  destination_prefix              :string
#  destination_reverse_billing     :boolean
#  dialpeer_fee                    :decimal(, )
#  dialpeer_initial_interval       :integer(4)
#  dialpeer_initial_rate           :decimal(, )
#  dialpeer_next_interval          :integer(4)
#  dialpeer_next_rate              :decimal(, )
#  dialpeer_prefix                 :string
#  dialpeer_reverse_billing        :boolean
#  diversion_in                    :string
#  diversion_out                   :string
#  dst_prefix_in                   :string
#  dst_prefix_out                  :string
#  dst_prefix_routing              :string
#  duration                        :integer(4)
#  early_media_present             :boolean
#  from_domain                     :string
#  global_tag                      :string
#  internal_disconnect_code        :integer(4)
#  internal_disconnect_reason      :string
#  is_last_cdr                     :boolean
#  is_redirected                   :boolean
#  lega_disconnect_code            :integer(4)
#  lega_disconnect_reason          :string
#  lega_identity                   :jsonb
#  lega_q850_cause                 :integer(2)
#  lega_q850_params                :string
#  lega_q850_text                  :string
#  lega_user_agent                 :string
#  legb_disconnect_code            :integer(4)
#  legb_disconnect_reason          :string
#  legb_local_tag                  :string
#  legb_outbound_proxy             :string
#  legb_q850_cause                 :integer(2)
#  legb_q850_params                :string
#  legb_q850_text                  :string
#  legb_ruri                       :string
#  legb_user_agent                 :string
#  local_tag                       :string
#  lrn                             :string
#  metadata                        :jsonb
#  p_charge_info_in                :string
#  pai_in                          :string
#  pai_out                         :string
#  pdd                             :float
#  ppi_in                          :string
#  ppi_out                         :string
#  privacy_in                      :string
#  privacy_out                     :string
#  profit                          :decimal(, )
#  routing_attempt                 :integer(4)
#  routing_delay                   :float
#  routing_tag_ids                 :integer(2)       is an Array
#  rpid_in                         :string
#  rpid_out                        :string
#  rpid_privacy_in                 :string
#  rpid_privacy_out                :string
#  rtt                             :float
#  ruri_domain                     :string
#  sign_orig_ip                    :string
#  sign_orig_local_ip              :string
#  sign_orig_local_port            :integer(4)
#  sign_orig_port                  :integer(4)
#  sign_term_ip                    :string
#  sign_term_local_ip              :string
#  sign_term_local_port            :integer(4)
#  sign_term_port                  :integer(4)
#  src_name_in                     :string
#  src_name_out                    :string
#  src_prefix_in                   :string
#  src_prefix_out                  :string
#  src_prefix_routing              :string
#  success                         :boolean
#  time_connect                    :timestamptz
#  time_end                        :timestamptz
#  time_limit                      :string
#  time_start                      :timestamptz      not null
#  to_domain                       :string
#  uuid                            :uuid
#  vendor_duration                 :integer(4)
#  vendor_price                    :decimal(, )
#  yeti_version                    :string
#  auth_orig_transport_protocol_id :integer(2)
#  customer_acc_external_id        :bigint(8)
#  customer_acc_id                 :integer(4)
#  customer_auth_external_id       :bigint(8)
#  customer_auth_id                :integer(4)
#  customer_external_id            :bigint(8)
#  customer_id                     :integer(4)
#  customer_invoice_id             :integer(4)
#  destination_id                  :integer(4)
#  destination_rate_policy_id      :integer(4)
#  dialpeer_id                     :integer(4)
#  disconnect_initiator_id         :integer(4)
#  dst_area_id                     :integer(4)
#  dst_country_id                  :integer(4)
#  dst_network_id                  :integer(4)
#  dump_level_id                   :integer(2)
#  failed_resource_id              :bigint(8)
#  failed_resource_type_id         :integer(2)
#  internal_disconnect_code_id     :integer(2)
#  lega_ss_status_id               :integer(2)
#  legb_ss_status_id               :integer(2)
#  lnp_database_id                 :integer(2)
#  node_id                         :integer(4)
#  orig_call_id                    :string
#  orig_gw_external_id             :bigint(8)
#  orig_gw_id                      :integer(4)
#  pop_id                          :integer(4)
#  rateplan_id                     :integer(4)
#  routing_group_id                :integer(4)
#  routing_plan_id                 :integer(4)
#  sign_orig_transport_protocol_id :integer(2)
#  sign_term_transport_protocol_id :integer(2)
#  src_area_id                     :integer(4)
#  src_country_id                  :integer(4)
#  src_network_id                  :integer(4)
#  term_call_id                    :string
#  term_gw_external_id             :bigint(8)
#  term_gw_id                      :integer(4)
#  vendor_acc_external_id          :bigint(8)
#  vendor_acc_id                   :integer(4)
#  vendor_external_id              :bigint(8)
#  vendor_id                       :integer(4)
#  vendor_invoice_id               :integer(4)
#
# Indexes
#
#  cdr_customer_acc_external_id_time_start_idx  (customer_acc_external_id,time_start) WHERE is_last_cdr
#  cdr_customer_acc_id_time_start_idx1          (customer_acc_id,time_start)
#  cdr_customer_id_time_start_idx               (customer_id,time_start)
#  cdr_id_idx                                   (id)
#  cdr_time_start_idx                           (time_start)
#  cdr_vendor_id_time_start_idx                 (vendor_id,time_start)
#

RSpec.describe Cdr::Cdr do
  describe '.add_partitions' do
    subject do
      Cdr::Cdr.add_partitions
    end

    def current_partitions
      Cdr::Cdr.pg_partition_class.partitions(Cdr::Cdr.table_name)
    end

    before do
      current_partitions.each do |partition|
        Cdr::Cdr.pg_partition_class.remove_partition(partition[:parent_table], partition[:name])
      end
      expect(current_partitions).to be_empty
    end

    let(:expected_partition_days) do
      from_date = Cdr::Cdr.pg_partition_depth_past.days.ago.to_date
      to_date = Cdr::Cdr.pg_partition_depth_future.days.from_now.to_date
      (from_date..to_date).to_a
    end

    it 'creates correct partitions' do
      subject
      expect(current_partitions).to match(
                                      expected_partition_days.map do |date|
                                        {
                                          id: be_present,
                                          parent_table: Cdr::Cdr.table_name,
                                          name: "cdr.cdr_#{date.strftime('%Y_%m_%d')}",
                                          date_from: Time.parse("#{date.strftime('%F')} 00:00:00 UTC"),
                                          date_to: Time.parse("#{(date + 1).strftime('%F')} 00:00:00 UTC"),
                                          partition_range: be_present
                                        }
                                      end
                                    )
    end

    context 'when today is 2021-04-01', freeze_time: Time.parse('2021-04-01 00:10:00 UTC') do
      context 'when no partitions exists' do
        it 'creates partitions for today, 3 days past, 3 days future' do
          expect(current_partitions.pluck(:name)).to eq []
          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_03_29',
                                                         'cdr.cdr_2021_03_30',
                                                         'cdr.cdr_2021_03_31',
                                                         'cdr.cdr_2021_04_01',
                                                         'cdr.cdr_2021_04_02',
                                                         'cdr.cdr_2021_04_03',
                                                         'cdr.cdr_2021_04_04'
                                                       ]
                                                     )
        end
      end

      context 'when partitions for today and last 3 days exists' do
        before do
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_DAY,
            Time.parse('2021-03-29 00:00:00 UTC')
          )
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_DAY,
            Time.parse('2021-03-30 00:00:00 UTC')
          )
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_DAY,
            Time.parse('2021-03-31 00:00:00 UTC')
          )
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_DAY,
            Time.parse('2021-04-01 00:00:00 UTC')
          )
        end

        it 'creates partitions for today, 3 days past, 3 days future' do
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_03_29',
                                                         'cdr.cdr_2021_03_30',
                                                         'cdr.cdr_2021_03_31',
                                                         'cdr.cdr_2021_04_01'
                                                       ]
                                                     )
          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_03_29',
                                                         'cdr.cdr_2021_03_30',
                                                         'cdr.cdr_2021_03_31',
                                                         'cdr.cdr_2021_04_01',
                                                         'cdr.cdr_2021_04_02',
                                                         'cdr.cdr_2021_04_03',
                                                         'cdr.cdr_2021_04_04'
                                                       ]
                                                     )
        end
      end

      context 'monthly partitions exists for this month and previous month' do
        before do
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_MONTH,
            Time.parse('2021-03-01 00:00:00 UTC')
          )
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_MONTH,
            Time.parse('2021-04-01 00:00:00 UTC')
          )
        end

        it 'does not create partitions' do
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_03',
                                                         'cdr.cdr_2021_04'
                                                       ]
                                                     )
          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_03',
                                                         'cdr.cdr_2021_04'
                                                       ]
                                                     )
        end
      end

      context 'monthly partitions exists for only this month' do
        before do
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_MONTH,
            Time.parse('2021-04-01 00:00:00 UTC')
          )
        end

        it 'does not create partitions' do
          expect(current_partitions.pluck(:name)).to eq ['cdr.cdr_2021_04']
          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_03_29',
                                                         'cdr.cdr_2021_03_30',
                                                         'cdr.cdr_2021_03_31',
                                                         'cdr.cdr_2021_04'
                                                       ]
                                                     )
        end
      end
    end

    context 'when today is 2021-04-28 (last day is 30)', freeze_time: Time.parse('2021-04-28 00:10:00 UTC') do
      context 'when no partitions exists' do
        it 'creates partitions for today, 3 days past, 3 days future' do
          expect(current_partitions.pluck(:name)).to eq []
          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_04_25',
                                                         'cdr.cdr_2021_04_26',
                                                         'cdr.cdr_2021_04_27',
                                                         'cdr.cdr_2021_04_28',
                                                         'cdr.cdr_2021_04_29',
                                                         'cdr.cdr_2021_04_30',
                                                         'cdr.cdr_2021_05_01'
                                                       ]
                                                     )
        end
      end

      context 'monthly partitions exists for only this month' do
        before do
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_MONTH,
            Time.parse('2021-04-01 00:00:00 UTC')
          )
        end

        it 'does not create partitions' do
          expect(current_partitions.pluck(:name)).to eq ['cdr.cdr_2021_04']

          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_04',
                                                         'cdr.cdr_2021_05_01'
                                                       ]
                                                     )
        end
      end
    end

    context 'when today is 2021-04-30 (last day of month)', freeze_time: Time.parse('2021-04-30 00:10:00 UTC') do
      context 'when no partitions exists' do
        it 'creates partitions for today, 3 days past, 3 days future' do
          expect(current_partitions.pluck(:name)).to eq []
          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_04_27',
                                                         'cdr.cdr_2021_04_28',
                                                         'cdr.cdr_2021_04_29',
                                                         'cdr.cdr_2021_04_30',
                                                         'cdr.cdr_2021_05_01',
                                                         'cdr.cdr_2021_05_02',
                                                         'cdr.cdr_2021_05_03'
                                                       ]
                                                     )
        end
      end

      context 'monthly partitions exists for only this month' do
        before do
          Cdr::Cdr.pg_partition_class.add_partition(
            Cdr::Cdr.table_name,
            PgPartition::INTERVAL_MONTH,
            Time.parse('2021-04-01 00:00:00 UTC')
          )
        end

        it 'does not create partitions' do
          expect(current_partitions.pluck(:name)).to eq ['cdr.cdr_2021_04']

          subject
          expect(current_partitions.pluck(:name)).to match(
                                                       [
                                                         'cdr.cdr_2021_04',
                                                         'cdr.cdr_2021_05_01',
                                                         'cdr.cdr_2021_05_02',
                                                         'cdr.cdr_2021_05_03'
                                                       ]
                                                     )
        end
      end
    end
  end
end
