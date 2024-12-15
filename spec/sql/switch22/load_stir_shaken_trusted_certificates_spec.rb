# frozen_string_literal: true

RSpec.describe 'switch22.load_stir_shaken_trusted_certificates' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_stir_shaken_trusted_certificates()'
  end
  let!(:crts) do
    [
      create(:stir_shaken_trusted_certificate)
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         crts.map do |c|
                           {
                             id: c.id,
                             name: c.name,
                             certificate: c.certificate,
                             updated_at: c.updated_at.utc.change(usec: 0)
                           }
                         end
                       )
  end
end
