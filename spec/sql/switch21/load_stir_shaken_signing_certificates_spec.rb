# frozen_string_literal: true

RSpec.describe 'switch21.load_stir_shaken_sigining_certificates' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch21.load_stir_shaken_signing_certificates()'
  end
  let!(:crts) do
    [
      create(:stir_shaken_signing_certificate)
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         crts.map do |c|
                           {
                             id: c.id,
                             name: c.name,
                             certificate: c.certificate,
                             key: c.key,
                             x5u: c.x5u,
                             updated_at: c.updated_at.utc.change(usec: 0)
                           }
                         end
                       )
  end
end
