# frozen_string_literal: true

RSpec.describe 'Info' do
  subject do
    visit info_path
  end

  include_context :login_as_admin

  it 'renders page' do
    subject
    expect(page).to have_content 'TOP10 tables in Routing database'
  end

  context 'when show_config_info = true' do
    before { allow(YetiConfig).to receive(:show_config_info).and_return(true) }

    it 'renders page' do
      subject

      within_panel 'Yeti-web config' do
        expect(page).to have_attribute_row('KEEP EXPIRED DESTINATIONS DAYS', exact_text: YetiConfig.keep_expired_destinations_days.presence || 'Empty')
        expect(page).to have_attribute_row('KEEP EXPIRED DIALPEERS DAYS', exact_text: YetiConfig.keep_expired_dialpeers_days.presence || 'Empty')
        expect(page).to have_attribute_row('CALLS MONITORING')
        expect(page).to have_attribute_row('WRITE ACCOUNT STATS', exact_text: YetiConfig.calls_monitoring.write_account_stats.presence || 'Empty')
        expect(page).to have_attribute_row('WRITE GATEWAY STATS', exact_text: YetiConfig.calls_monitoring.write_gateway_stats.presence || 'Empty')
        expect(page).to have_attribute_row('API')
        expect(page).to have_attribute_row('TOKEN LIFETIME', exact_text: YetiConfig.api.token_lifetime.presence || 'Empty')
        expect(page).to have_attribute_row('CDR EXPORT')
        expect(page).to have_attribute_row('DIR PATH', exact_text: YetiConfig.cdr_export.dir_path.presence || 'Empty')
        expect(page).to have_attribute_row('DELETE URL', exact_text: YetiConfig.cdr_export.delete_url.presence || 'Empty')
        expect(page).to have_attribute_row('ROLE POLICY')
        expect(page).to have_attribute_row('WHEN NO CONFIG', exact_text: YetiConfig.role_policy.when_no_config.presence || 'Empty')
        expect(page).to have_attribute_row('WHEN NO POLICY CLASS', exact_text: YetiConfig.role_policy.when_no_policy_class.presence || 'Empty')
        expect(page).to have_attribute_row('PARTITION REMOVE DELAY')
        expect(page).to have_attribute_row('CDR_CDR', exact_text: YetiConfig.partition_remove_delay['cdr.cdr'] || 'Empty')
        expect(page).to have_attribute_row('AUTH_LOG_AUTH_LOG', exact_text: YetiConfig.partition_remove_delay['auth_log.auth_log'] || 'Empty')
        expect(page).to have_attribute_row('RTP_STATISTICS_RX_STREAMS', exact_text: YetiConfig.partition_remove_delay['rtp_statistics.rx_streams'] || 'Empty')
        expect(page).to have_attribute_row('RTP_STATISTICS_TX_STREAMS', exact_text: YetiConfig.partition_remove_delay['rtp_statistics.tx_streams'] || 'Empty')
        expect(page).to have_attribute_row('LOGS_API_REQUESTS', exact_text: YetiConfig.partition_remove_delay['logs.api_requests'] || 'Empty')
        expect(page).to have_attribute_row('PROMETHEUS')
        expect(page).to have_attribute_row('ENABLED', exact_text: YetiConfig.prometheus.enabled ? 'Yes' : 'No')
        expect(page).to have_attribute_row('DEFAULT_LABELS')
        expect(page).to have_attribute_row('HOST', exact_text: YetiConfig.prometheus.host.presence || 'Empty')
        expect(page).to have_attribute_row('SENTRY')
        expect(page).to have_attribute_row('ENABLED', exact_text: YetiConfig.sentry.enabled ? 'Yes' : 'No')
        expect(page).to have_attribute_row('NODE_NAME', exact_text: YetiConfig.sentry.node_name.presence || 'Empty')
        expect(page).to have_attribute_row('ENVIRONMENT', exact_text: YetiConfig.sentry.environment.presence || 'Empty')
        expect(page).to have_attribute_row('VERSIONING_DISABLE_FOR_MODELS', text: YetiConfig.versioning_disable_for_models.join("\n").presence || 'Empty')
      end
    end
  end

  context 'when show_config_info = false' do
    before { allow(YetiConfig).to receive(:show_config_info).and_return(false) }

    it 'renders page' do
      subject

      expect(page).not_to have_panel('Yeti-web config')
    end
  end

  context 'when show_config_info = nil' do
    before { allow(YetiConfig).to receive(:show_config_info).and_return(nil) }

    it 'renders page' do
      subject

      expect(page).not_to have_panel('Yeti-web config')
    end
  end
end
