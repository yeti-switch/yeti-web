# frozen_string_literal: true

RSpec.describe 'config/yeti_web.yml' do
  subject do
    YetiConfig.to_h.deep_symbolize_keys
  end

  let(:expected_structure) do
    {
      site_title: be_kind_of(String),
      site_title_image: be_kind_of(String),
      calls_monitoring: {
        write_account_stats: be_one_of(true, false),
        write_gateway_stats: be_one_of(true, false)
      },
      api: {
        token_lifetime: be_kind_of(Integer)
      },
      cdr_export: {
        dir_path: be_kind_of(String),
        delete_url: be_kind_of(String)
      },
      role_policy: {
        when_no_config: be_one_of('allow', 'disallow', 'raise'),
        when_no_policy_class: be_one_of('allow', 'disallow', 'raise')
      },
      partition_remove_delay: {
        'cdr.cdr': anything,
        'auth_log.auth_log': anything,
        'rtp_statistics.rx_streams': anything,
        'rtp_statistics.tx_streams': anything,
        'logs.api_requests': anything
      },
      prometheus: {
        enabled: anything,
        host: a_kind_of(String),
        port: a_kind_of(Integer),
        default_labels: a_kind_of(Hash)
      },
      sentry: {
        enabled: boolean,
        dsn: a_kind_of(String),
        environment: a_kind_of(String),
        node_name: a_kind_of(String)
      },
      versioning_disable_for_models: a_kind_of(Array),
      keep_expired_dialpeers_days: a_kind_of(String),
      keep_expired_destinations_days: a_kind_of(String)
    }
  end

  it 'has correct structure' do
    # expect(subject).to match(expected_structure)
    expect(subject.keys).to(
      match_array(expected_structure.keys),
      "expected root keys to be #{expected_structure.keys}, but found #{subject.keys}"
    )
    subject.each do |k, v|
      expect(v).to(
        match(expected_structure[k]),
        "expected nested #{k} to match #{expected_structure[k]}, but found #{v}"
      )
    end
  end

  context 'validate :versioning_disable_for_models' do
    before do
      # Stub the config
      allow(YetiConfig.role_policy).to receive(:when_no_config).and_return('disallow')
      allow(YetiConfig.role_policy).to receive(:when_no_policy_class).and_return('raise')
      allow(YetiConfig).to receive(:versioning_disable_for_models).and_return(
        [
          'Routing::NumberlistItem',
          'Node'
        ]
      )
    end

    let(:vendor) { FactoryBot.create(:vendor) }
    let(:account) { FactoryBot.create(:account, contractor: vendor) }
    let(:numberlist_item) { FactoryBot.create(:numberlist_item) }
    let(:node) { FactoryBot.create(:node) }

    it 'should create a new version on object creation only for models non declared in the config' do
      expect(vendor.versions.count).to eq(1)
      expect(account.versions.count).to eq(1)
      expect(numberlist_item.versions.count).to eq(0)
      expect(node.versions.count).to eq(0)
    end

    it 'should create a new version after object modification only for models non declared in the config' do
      expect { vendor.update(name: 'Test Name') }.to change { vendor.versions.count }.by(1)
      expect { account.update(name: 'Test Name') }.to change { account.versions.count }.by(1)
      expect { numberlist_item.update(dst_rewrite_rule: 'any') }.to change { numberlist_item.versions.count }.by(0)
      expect { node.update(name: 'Test Name') }.to change { node.versions.count }.by(0)
    end

    it 'should create a new version after deleting the object only for models non declared in the config' do
      expect { account.destroy }.to change { account.versions.count }.by(1)
      expect { vendor.destroy }.to change { vendor.versions.count }.by(1)
      expect { numberlist_item.destroy }.to change { numberlist_item.versions.count }.by(0)
      expect { node.destroy }.to change { node.versions.count }.by(0)
    end
  end
end
