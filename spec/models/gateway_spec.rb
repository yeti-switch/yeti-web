# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateways
#
#  id                               :integer(4)       not null, primary key
#  acd_limit                        :float            default(0.0), not null
#  allow_1xx_without_to_tag         :boolean          default(FALSE), not null
#  allow_origination                :boolean          default(TRUE), not null
#  allow_termination                :boolean          default(TRUE), not null
#  asr_limit                        :float            default(0.0), not null
#  auth_enabled                     :boolean          default(FALSE), not null
#  auth_from_domain                 :string
#  auth_from_user                   :string
#  auth_password                    :string
#  auth_user                        :string
#  codecs_payload_order             :string           default("")
#  codecs_prefer_transcoding_for    :string           default("")
#  dialog_nat_handling              :boolean          default(TRUE), not null
#  diversion_domain                 :string
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dns_srv_failover_timer           :integer(4)       default(2000), not null
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  enabled                          :boolean          not null
#  fake_180_timer                   :integer(2)
#  filter_noaudio_streams           :boolean          default(FALSE), not null
#  force_cancel_routeset            :boolean          default(FALSE), not null
#  force_dtmf_relay                 :boolean          default(FALSE), not null
#  force_one_way_early_media        :boolean          default(FALSE), not null
#  force_symmetric_rtp              :boolean          default(TRUE), not null
#  host                             :string
#  incoming_auth_password           :string
#  incoming_auth_username           :string
#  is_shared                        :boolean          default(FALSE), not null
#  locked                           :boolean          default(FALSE), not null
#  max_30x_redirects                :integer(2)       default(0), not null
#  max_transfers                    :integer(2)       default(0), not null
#  name                             :string           not null
#  orig_append_headers_reply        :string           is an Array
#  orig_append_headers_req          :string           is an Array
#  orig_force_outbound_proxy        :boolean          default(FALSE), not null
#  orig_next_hop                    :string
#  orig_outbound_proxy              :string
#  orig_use_outbound_proxy          :boolean          default(FALSE), not null
#  origination_capacity             :integer(2)
#  pai_domain                       :string
#  port                             :integer(4)
#  prefer_existing_codecs           :boolean          default(TRUE), not null
#  preserve_anonymous_from_domain   :boolean          default(FALSE), not null
#  priority                         :integer(4)       default(100), not null
#  proxy_media                      :boolean          default(TRUE), not null
#  relay_hold                       :boolean          default(FALSE), not null
#  relay_options                    :boolean          default(FALSE), not null
#  relay_prack                      :boolean          default(FALSE), not null
#  relay_reinvite                   :boolean          default(FALSE), not null
#  relay_update                     :boolean          default(FALSE), not null
#  resolve_ruri                     :boolean          default(FALSE), not null
#  ringing_timeout                  :integer(4)
#  rtp_acl                          :inet             is an Array
#  rtp_force_relay_cn               :boolean          default(TRUE), not null
#  rtp_interface_name               :string
#  rtp_ping                         :boolean          default(FALSE), not null
#  rtp_relay_timestamp_aligning     :boolean          default(FALSE), not null
#  rtp_timeout                      :integer(4)       default(30), not null
#  sdp_alines_filter_list           :string
#  send_lnp_information             :boolean          default(FALSE), not null
#  short_calls_limit                :float            default(1.0), not null
#  single_codec_in_200ok            :boolean          default(FALSE), not null
#  sip_interface_name               :string
#  sip_timer_b                      :integer(4)       default(8000), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  sst_accept501                    :boolean          default(TRUE), not null
#  sst_enabled                      :boolean          default(FALSE)
#  sst_maximum_timer                :integer(4)       default(50), not null
#  sst_minimum_timer                :integer(4)       default(50), not null
#  sst_session_expires              :integer(4)       default(50)
#  suppress_early_media             :boolean          default(FALSE), not null
#  symmetric_rtp_nonstop            :boolean          default(FALSE), not null
#  term_append_headers_req          :string           is an Array
#  term_force_outbound_proxy        :boolean          default(FALSE), not null
#  term_next_hop                    :string
#  term_next_hop_for_replies        :boolean          default(FALSE), not null
#  term_outbound_proxy              :string
#  term_use_outbound_proxy          :boolean          default(FALSE), not null
#  termination_capacity             :integer(2)
#  to_rewrite_result                :string
#  to_rewrite_rule                  :string
#  transit_headers_from_origination :string
#  transit_headers_from_termination :string
#  try_avoid_transcoding            :boolean          default(FALSE), not null
#  weight                           :integer(2)       default(100), not null
#  codec_group_id                   :integer(4)       default(1), not null
#  contractor_id                    :integer(4)       not null
#  diversion_send_mode_id           :integer(2)       default(1), not null
#  dtmf_receive_mode_id             :integer(2)       default(1), not null
#  dtmf_send_mode_id                :integer(2)       default(1), not null
#  external_id                      :bigint(8)
#  gateway_group_id                 :integer(4)
#  lua_script_id                    :integer(2)
#  media_encryption_mode_id         :integer(2)       default(0), not null
#  network_protocol_priority_id     :integer(2)       default(0), not null
#  orig_disconnect_policy_id        :integer(4)
#  orig_proxy_transport_protocol_id :integer(2)       default(1), not null
#  pai_send_mode_id                 :integer(2)       default(0), not null
#  pop_id                           :integer(4)
#  privacy_mode_id                  :integer(2)       default(0), not null
#  radius_accounting_profile_id     :integer(2)
#  registered_aor_mode_id           :integer(2)       default(0), not null
#  rel100_mode_id                   :integer(2)       default(4), not null
#  rx_inband_dtmf_filtering_mode_id :integer(2)       default(1), not null
#  sdp_alines_filter_type_id        :integer(4)       default(0), not null
#  sdp_c_location_id                :integer(4)       default(2), not null
#  sensor_id                        :integer(2)
#  sensor_level_id                  :integer(2)       default(1), not null
#  session_refresh_method_id        :integer(4)       default(3), not null
#  sip_schema_id                    :integer(2)       default(1), not null
#  stir_shaken_crt_id               :integer(2)
#  stir_shaken_mode_id              :integer(2)       default(0), not null
#  term_disconnect_policy_id        :integer(4)
#  term_proxy_transport_protocol_id :integer(2)       default(1), not null
#  termination_dst_numberlist_id    :integer(2)
#  termination_src_numberlist_id    :integer(2)
#  transparent_dialog_id            :boolean          default(FALSE), not null
#  transport_protocol_id            :integer(2)       default(1), not null
#  tx_inband_dtmf_filtering_mode_id :integer(2)       default(1), not null
#
# Indexes
#
#  gateways_contractor_id_idx      (contractor_id)
#  gateways_dst_numberlist_id_idx  (termination_dst_numberlist_id)
#  gateways_name_unique            (name) UNIQUE
#  gateways_src_numberlist_id_idx  (termination_src_numberlist_id)
#
# Foreign Keys
#
#  gateways_codec_group_id_fkey                    (codec_group_id => codec_groups.id)
#  gateways_contractor_id_fkey                     (contractor_id => contractors.id)
#  gateways_diversion_send_mode_id_fkey            (diversion_send_mode_id => gateway_diversion_send_modes.id)
#  gateways_dtmf_receive_mode_id_fkey              (dtmf_receive_mode_id => dtmf_receive_modes.id)
#  gateways_dtmf_send_mode_id_fkey                 (dtmf_send_mode_id => dtmf_send_modes.id)
#  gateways_gateway_group_id_fkey                  (gateway_group_id => gateway_groups.id)
#  gateways_lua_script_id_fkey                     (lua_script_id => lua_scripts.id)
#  gateways_media_encryption_mode_id_fkey          (media_encryption_mode_id => gateway_media_encryption_modes.id)
#  gateways_network_protocol_priority_id_fkey      (network_protocol_priority_id => gateway_network_protocol_priorities.id)
#  gateways_orig_disconnect_policy_id_fkey         (orig_disconnect_policy_id => disconnect_policy.id)
#  gateways_orig_proxy_transport_protocol_id_fkey  (orig_proxy_transport_protocol_id => transport_protocols.id)
#  gateways_pop_id_fkey                            (pop_id => pops.id)
#  gateways_radius_accounting_profile_id_fkey      (radius_accounting_profile_id => radius_accounting_profiles.id)
#  gateways_rel100_mode_id_fkey                    (rel100_mode_id => gateway_rel100_modes.id)
#  gateways_rx_inband_dtmf_filtering_mode_id_fkey  (rx_inband_dtmf_filtering_mode_id => gateway_inband_dtmf_filtering_modes.id)
#  gateways_sdp_alines_filter_type_id_fkey         (sdp_alines_filter_type_id => filter_types.id)
#  gateways_sdp_c_location_id_fkey                 (sdp_c_location_id => sdp_c_location.id)
#  gateways_sensor_id_fkey                         (sensor_id => sensors.id)
#  gateways_sensor_level_id_fkey                   (sensor_level_id => sensor_levels.id)
#  gateways_session_refresh_method_id_fkey         (session_refresh_method_id => session_refresh_methods.id)
#  gateways_stir_shaken_crt_id_fkey                (stir_shaken_crt_id => stir_shaken_signing_certificates.id)
#  gateways_term_disconnect_policy_id_fkey         (term_disconnect_policy_id => disconnect_policy.id)
#  gateways_term_proxy_transport_protocol_id_fkey  (term_proxy_transport_protocol_id => transport_protocols.id)
#  gateways_transport_protocol_id_fkey             (transport_protocol_id => transport_protocols.id)
#  gateways_tx_inband_dtmf_filtering_mode_id_fkey  (tx_inband_dtmf_filtering_mode_id => gateway_inband_dtmf_filtering_modes.id)
#

RSpec.describe Gateway, type: :model do
  it 'validates correctly' do
    is_expected.to validate_numericality_of(:max_30x_redirects).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:max_transfers).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:fake_180_timer).is_less_than_or_equal_to(ApplicationRecord::PG_MAX_SMALLINT)
    is_expected.to validate_presence_of(:rtp_timeout)
    is_expected.to validate_numericality_of(:rtp_timeout).is_less_than_or_equal_to(Gateway::RTP_TIMEOUT_MAX)
    is_expected.to validate_numericality_of(:rtp_timeout).is_greater_than_or_equal_to(Gateway::RTP_TIMEOUT_MIN)
  end

  shared_examples :validation_error_on_is_shared_change do
    let(:expected_error_message) {}

    let(:full_expected_error_message) do
      "Validation failed: Is shared #{expected_error_message}"
    end

    subject do
      record.update!(is_shared: false)
    end

    it 'raise error' do
      expect do
        subject
      end.to raise_error(ActiveRecord::RecordInvalid, full_expected_error_message)
    end
  end

  context 'uncheck is_shared' do
    let(:record) { create(:gateway, is_shared: true) }

    context 'when has linked CustomersAuth' do
      include_examples :validation_error_on_is_shared_change do
        before { create(:customers_auth, gateway: record) }
        let(:expected_error_message) do
          I18n.t('activerecord.errors.models.gateway.attributes.contractor.cant_be_changed_when_linked_to_customers_auth')
        end
      end
    end

    context 'when has linked Dialpeer' do
      include_examples :validation_error_on_is_shared_change do
        before { create(:dialpeer, gateway: record) }

        let(:expected_error_message) do
          I18n.t('activerecord.errors.models.gateway.attributes.contractor.cant_be_changed_when_linked_to_dialpeer')
        end
      end
    end
  end

  context 'scope :termination_contractor_id_eq' do
    before do
      # in scope
      @record = create(:gateway, is_shared: false, allow_termination: true, name: 'b-gateway')
      @record_2 = create(:gateway, is_shared: true, allow_termination: true, name: 'a-gateway')
    end

    # out of scope
    before do
      # other vendor
      create(:gateway, allow_termination: true)
      # shared but not for termination
      create(:gateway, allow_termination: false, is_shared: true)
      # same vendor but not for termination
      create(:gateway, allow_termination: false, contractor: vendor)
    end

    let(:vendor) { @record.vendor }

    subject do
      described_class.termination_contractor_id_eq(vendor.id)
    end

    it 'allow_termination is mandatory, then look for shared or vendors gateways, order by name' do
      expect(subject.pluck(:id)).to match_array([@record_2.id, @record.id])
    end
  end

  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let!(:vendor) { FactoryBot.create(:vendor) }
    let!(:codec_group) { FactoryBot.create(:codec_group) }

    let(:create_params) do
      {
        contractor: vendor,
        codec_group: codec_group,
        name: 'test',
        allow_termination: false,
        enabled: false
      }
    end

    include_examples :does_not_call_event_with, :reload_incoming_auth
    include_examples :creates_record
    include_examples :changes_records_qty_of, described_class, by: 1

    context 'with auth credentials' do
      let(:create_params) { super().merge(incoming_auth_username: 'qwe', incoming_auth_password: 'asd') }

      include_examples :calls_event_with, :reload_incoming_auth
      include_examples :creates_record
      include_examples :changes_records_qty_of, described_class, by: 1
    end

    context 'with raw IPv6 host' do
      let(:create_params) { super().merge(host: 'dd:ee:aa:dd::') }
      it 'should convert address to reference' do
        subject
        expect(subject.host).to eq('[dd:ee:aa:dd::]')
      end
    end

    context 'with raw IPv6 reference host' do
      let(:create_params) { super().merge(host: '[dd:ee:aa:dd::]') }
      it 'should convert address to reference' do
        subject
        expect(subject.host).to eq('[dd:ee:aa:dd::]')
      end
    end

    context 'with raw IPv4 host' do
      let(:create_params) { super().merge(host: '1.2.3.4') }
      it 'should not change value' do
        subject
        expect(subject.host).to eq('1.2.3.4')
      end
    end

    context 'with not IPv4 nor IPv6 host' do
      let(:create_params) { super().merge(host: '11:222sdasda') }
      it 'should not change value' do
        subject
        expect(subject.host).to eq('11:222sdasda')
      end
    end
  end

  describe '#update' do
    subject do
      record.update(update_params)
    end

    let!(:record) { FactoryBot.create(:gateway, record_attrs) }
    let(:record_attrs) { { enabled: false } }

    context 'without incoming_auth' do
      context 'when change enable false->true' do
        let(:record_attrs) { super().merge(enabled: false) }
        let(:update_params) { { enabled: true } }

        include_examples :updates_record
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change enable true->false' do
        let(:record_attrs) { super().merge(enabled: true) }
        let(:update_params) { { enabled: false } }

        include_examples :updates_record
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change incoming_auth_username to something' do
        let(:update_params) { { incoming_auth_username: 'qwe' } }

        include_examples :does_not_update_record, errors: {
          incoming_auth_password: "can't be blank"
        }
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change incoming_auth_password to something' do
        let(:update_params) { { incoming_auth_password: 'qwe' } }

        include_examples :does_not_update_record, errors: {
          incoming_auth_username: "can't be blank"
        }
        include_examples :does_not_call_event_with, :reload_incoming_auth
      end

      context 'when change incoming_auth_username and incoming_auth_password to something' do
        let(:update_params) { { incoming_auth_username: 'qwe', incoming_auth_password: 'asd' } }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth
      end
    end

    context 'with incoming_auth' do
      let(:record_attrs) { super().merge(incoming_auth_username: 'qwe', incoming_auth_password: 'asd') }

      context 'when change enable false->true' do
        let(:record_attrs) { super().merge(enabled: false) }
        let(:update_params) { { enabled: true } }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth
      end

      context 'when change enable true->false' do
        let(:record_attrs) { super().merge(enabled: true) }
        let(:update_params) { { enabled: false } }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth
      end

      context 'when clear incoming_auth_username and incoming_auth_password' do
        let(:update_params) { { incoming_auth_username: nil, incoming_auth_password: nil } }
        before { record.customers_auths.where(require_incoming_auth: true).delete_all }

        include_examples :updates_record
        include_examples :calls_event_with, :reload_incoming_auth

        context 'when was enabled' do
          let(:record_attrs) { super().merge(enabled: true) }

          include_examples :updates_record
          include_examples :calls_event_with, :reload_incoming_auth
        end
      end
    end
  end

  describe '#destroy' do
    subject do
      record.destroy
    end

    let!(:record) { FactoryBot.create(:gateway, record_attrs) }
    let(:record_attrs) { { enabled: false } }

    context 'without incoming_auth' do
      include_examples :changes_records_qty_of, described_class, by: -1
      include_examples :destroys_record
      include_examples :does_not_call_event_with, :reload_incoming_auth
    end

    context 'with incoming_auth' do
      let(:record_attrs) { super().merge(incoming_auth_username: 'qwe', incoming_auth_password: 'asd') }

      include_examples :changes_records_qty_of, described_class, by: -1
      include_examples :destroys_record
      include_examples :calls_event_with, :reload_incoming_auth
    end

    context 'when Gateway is linked to RateManagement Project' do
      let!(:projects) { FactoryBot.create_list(:rate_management_project, 3, :filled, gateway: record, vendor: record.vendor) }

      it 'should raise validation error' do
        subject

        error_message = "Can't be deleted because linked to Rate Management Project(s) ##{projects.map(&:id).join(', #')}"
        expect(record.errors.to_a).to contain_exactly error_message

        expect(Gateway).to be_exists(record.id)
      end
    end

    context 'when Gateway is linked to RateManagement Pricelist Item' do
      let(:new_gateway) { FactoryBot.create(:gateway) }
      let(:project) { FactoryBot.create(:rate_management_project, :filled, vendor: new_gateway.vendor, gateway: new_gateway) }
      let!(:pricelists) do
        FactoryBot.create_list(:rate_management_pricelist, 2, pricelist_state, project: project)
      end
      let(:pricelist_state) { :new }
      let!(:pricelist_items) do
        [
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[0], gateway: record),
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[1], gateway: record)
        ].flatten
      end

      it 'should raise validation error' do
        subject

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
        expect(record.errors.to_a).to contain_exactly error_message

        expect(Gateway).to be_exists(record.id)
      end

      context 'when pricelist has dialpeers_detected state' do
        let(:pricelist_state) { :dialpeers_detected }

        it 'should raise validation error' do
          subject

          error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
          expect(record.errors.to_a).to contain_exactly error_message

          expect(Gateway).to be_exists(record.id)
        end
      end

      context 'when pricelist has applied state' do
        let(:pricelist_state) { :applied }

        it 'should delete gateway' do
          expect { subject }.not_to raise_error
          expect(Gateway).not_to be_exists(record.id)

          pricelist_items.each do |item|
            expect(item.reload.gateway_id).to be_nil
          end
        end
      end
    end

    context 'when Gateway is linked to RateManagement Project and Pricelist Items' do
      let!(:project) { FactoryBot.create(:rate_management_project, :filled, gateway: record, vendor: record.vendor) }
      let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, project: project, items_qty: 1) }

      it 'should raise validation error' do
        subject

        error_messages = [
          "Can't be deleted because linked to Rate Management Project(s) ##{project.id}",
          "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist.id}"
        ]
        expect(record.errors).to contain_exactly *error_messages

        expect(described_class).to be_exists(record.id)
      end
    end
  end
end
