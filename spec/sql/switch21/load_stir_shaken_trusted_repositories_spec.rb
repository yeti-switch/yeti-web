# frozen_string_literal: true

RSpec.describe 'switch21.load_stir_shaken_trusted_repositories' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch21.load_stir_shaken_trusted_repositories()'
  end
  let!(:crts) do
    [
      create(:stir_shaken_trusted_repository),
      create(:stir_shaken_trusted_repository),
      create(:stir_shaken_trusted_repository),
      create(:stir_shaken_trusted_repository),
      create(:stir_shaken_trusted_repository)
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         crts.map do |c|
                           {
                             id: c.id,
                             url_pattern: c.url_pattern,
                             validate_https_certificate: c.validate_https_certificate,
                             updated_at: c.updated_at.utc.change(usec: 0)
                           }
                         end
                       )
  end
end
