# frozen_string_literal: true

RSpec.describe 'switch20.load_stir_shaken_trusted_certificates' do
  subject do
    yeti_select_all('SELECT * FROM switch20.load_stir_shaken_trusted_certificates()')
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
