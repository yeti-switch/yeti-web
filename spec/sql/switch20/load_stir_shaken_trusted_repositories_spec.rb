# frozen_string_literal: true

RSpec.describe 'switch20.load_stir_shaken_trusted_repositories' do
  subject do
    yeti_select_all('SELECT * FROM switch20.load_stir_shaken_trusted_repositories()')
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
