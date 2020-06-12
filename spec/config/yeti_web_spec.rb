# frozen_string_literal: true

RSpec.describe 'config/yeti_web.yml' do
  subject do
    Rails.configuration.yeti_web.deep_symbolize_keys
  end

  let(:expected_structure) do
    {
      site_title: be_kind_of(String),
      site_title_image: be_kind_of(String),
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
        'rtp_statistics.streams': anything,
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
      }
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
end
