# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Gateway, :js do
  include_context :login_as_admin
  let!(:_gateways) { FactoryBot.create_list :gateway, 3 }
  let!(:codec_group) { FactoryBot.create :codec_group }
  let(:pg_max_smallint) { ApplicationRecord::PG_MAX_SMALLINT }
  let(:success_message) { I18n.t 'flash.actions.batch_actions.batch_update.job_scheduled' }

  before do
    visit gateways_path
    click_button 'Update batch'
    expect(page).to have_selector('.ui-dialog')
  end

  subject do
    fill_batch_form
    click_button 'OK'
  end

  let(:assign_params) do
    {
      enabled: false,
      priority: '1',
      weight: '12',
      is_shared: false,
      acd_limit: '1',
      asr_limit: '1',
      short_calls_limit: '1',
      force_symmetric_rtp: false,
      rtp_ping: true,
      proxy_media: false,
      host: 'host.example.com',
      codec_group_id: codec_group.id.to_s,
      filter_noaudio_streams: true,
      try_avoid_transcoding: false,
      single_codec_in_200ok: true,
      symmetric_rtp_nonstop: false,
      force_one_way_early_media: true,
      rtp_force_relay_cn: false,
      rtp_interface_name: 'rtp0',
      media_encryption_mode_id: '1',
      ice_mode_id: Gateway::ICE_MODE_ACCEPT.to_s,
      rtcp_mux_mode_id: Gateway::RTCP_MUX_MODE_DISABLED.to_s,
      rtcp_feedback_mode_id: Gateway::RTCP_FEEDBACK_MODE_INITIATE.to_s,
      rtp_acl: '192.168.0.0/24,10.0.0.1'
    }
  end

  let(:fill_batch_form) do
    if assign_params.key? :enabled
      check :Enabled
      select_by_value assign_params[:enabled], from: :enabled
    end

    if assign_params.key? :priority
      check :Priority
      fill_in :priority, with: assign_params[:priority]
    end

    if assign_params.key? :weight
      check :Weight
      fill_in :weight, with: assign_params[:weight]
    end

    if assign_params.key? :is_shared
      check :Is_shared
      select_by_value assign_params[:is_shared], from: :is_shared
    end

    if assign_params.key? :acd_limit
      check :Acd_limit
      fill_in :acd_limit, with: assign_params[:acd_limit]
    end

    if assign_params.key? :asr_limit
      check :Asr_limit
      fill_in :asr_limit, with: assign_params[:asr_limit]
    end

    if assign_params.key? :short_calls_limit
      check :Short_calls_limit
      fill_in :short_calls_limit, with: assign_params[:short_calls_limit]
    end

    if assign_params.key? :force_symmetric_rtp
      check :Force_symmetric_rtp
      select_by_value assign_params[:force_symmetric_rtp], from: :force_symmetric_rtp
    end

    if assign_params.key? :rtp_ping
      check :Rtp_ping
      select_by_value assign_params[:rtp_ping], from: :rtp_ping
    end

    if assign_params.key? :proxy_media
      check :Proxy_media
      select_by_value assign_params[:proxy_media], from: :proxy_media
    end

    if assign_params.key? :host
      check :Host
      fill_in :host, with: assign_params[:host]
    end

    if assign_params.key? :codec_group_id
      check :Codec_group_id
      select_by_value assign_params[:codec_group_id], from: :codec_group_id
    end

    if assign_params.key? :filter_noaudio_streams
      check :Filter_noaudio_streams
      select_by_value assign_params[:filter_noaudio_streams], from: :filter_noaudio_streams
    end

    if assign_params.key? :try_avoid_transcoding
      check :Try_avoid_transcoding
      select_by_value assign_params[:try_avoid_transcoding], from: :try_avoid_transcoding
    end

    if assign_params.key? :single_codec_in_200ok
      check :Single_codec_in_200ok
      select_by_value assign_params[:single_codec_in_200ok], from: :single_codec_in_200ok
    end

    if assign_params.key? :symmetric_rtp_nonstop
      check :Symmetric_rtp_nonstop
      select_by_value assign_params[:symmetric_rtp_nonstop], from: :symmetric_rtp_nonstop
    end

    if assign_params.key? :force_one_way_early_media
      check :Force_one_way_early_media
      select_by_value assign_params[:force_one_way_early_media], from: :force_one_way_early_media
    end

    if assign_params.key? :rtp_force_relay_cn
      check :Rtp_force_relay_cn
      select_by_value assign_params[:rtp_force_relay_cn], from: :rtp_force_relay_cn
    end

    if assign_params.key? :rtp_interface_name
      check :Rtp_interface_name
      fill_in :rtp_interface_name, with: assign_params[:rtp_interface_name]
    end

    if assign_params.key? :media_encryption_mode_id
      check :Media_encryption_mode_id
      select_by_value assign_params[:media_encryption_mode_id], from: :media_encryption_mode_id
    end

    if assign_params.key? :ice_mode_id
      check :Ice_mode_id
      select_by_value assign_params[:ice_mode_id], from: :ice_mode_id
    end

    if assign_params.key? :rtcp_mux_mode_id
      check :Rtcp_mux_mode_id
      select_by_value assign_params[:rtcp_mux_mode_id], from: :rtcp_mux_mode_id
    end

    if assign_params.key? :rtcp_feedback_mode_id
      check :Rtcp_feedback_mode_id
      select_by_value assign_params[:rtcp_feedback_mode_id], from: :rtcp_feedback_mode_id
    end

    if assign_params.key? :rtp_acl
      check :Rtp_acl
      fill_in :rtp_acl, with: assign_params[:rtp_acl]
    end
  end

  context 'check validates' do
    context 'when :priority have wrong float value' do
      let(:assign_params) { { priority: '0' } }

      it 'should have error: must be greater than zero' do
        subject
        expect(page).to have_selector '.flash', text: 'must be greater than 0'
      end
    end

    context 'when all fields filled with valid values' do
      it 'should pass validations' do
        expect do
          subject
          expect(page).to have_selector '.flash', text: success_message
        end.to have_enqueued_job(AsyncBatchUpdateJob).on_queue('batch_actions').with 'Gateway', be_present, assign_params, be_present
      end
    end
  end
end
