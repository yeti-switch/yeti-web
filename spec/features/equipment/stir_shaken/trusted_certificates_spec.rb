# frozen_string_literal: true

RSpec.describe 'Equipment STIR/SHAKEN trusted certificates' do
  include_context :login_as_admin

  let!(:trusted_certificate) { create(:stir_shaken_trusted_certificate) }

  describe 'index' do
    subject do
      visit '/equipment_stir_shaken_trusted_certificates'
    end

    it 'displays certificate details' do
      subject

      expect(page).to have_table_cell(column: 'Certificate Details', text: 'Unable to decode certificate:')
    end
  end

  describe 'show' do
    subject do
      visit "/equipment_stir_shaken_trusted_certificates/#{trusted_certificate.id}"
    end

    it 'displays certificate details' do
      subject

      expect(page).to have_text(/Certificate Details/i)
      expect(page).to have_text('Unable to decode certificate:')
    end
  end
end
