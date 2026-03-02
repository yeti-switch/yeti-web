# frozen_string_literal: true

RSpec.describe 'Equipment STIR/SHAKEN signing certificates' do
  include_context :login_as_admin

  let!(:signing_certificate) { create(:stir_shaken_signing_certificate, :with_certificate) }
  let!(:signing_certificate_with_tn) { create(:stir_shaken_signing_certificate, :with_tn_auth_list) }

  describe 'index' do
    subject do
      visit '/equipment_stir_shaken_signing_certificates'
    end

    it 'displays certificate details' do
      subject

      expect(page).to have_table_cell(column: 'Certificate Details', text: 'Subject: CN=Test SHAKEN')
    end

    it 'displays certificate with TNAuthList' do
      subject

      expect(page).to have_table_cell(column: 'Certificate Details', text: 'TNAuthList:')
      expect(page).to have_table_cell(column: 'Certificate Details', text: 'SPC: 1234')
    end
  end

  describe 'show' do
    context 'certificate without TNAuthList' do
      subject do
        visit "/equipment_stir_shaken_signing_certificates/#{signing_certificate.id}"
      end

      it 'displays certificate details' do
        subject

        expect(page).to have_text(/Certificate Details/i)
        expect(page).to have_text('Subject: CN=Test SHAKEN')
        expect(page).not_to have_text('TNAuthList')
      end
    end

    context 'certificate with TNAuthList' do
      subject do
        visit "/equipment_stir_shaken_signing_certificates/#{signing_certificate_with_tn.id}"
      end

      it 'displays certificate details with TNAuthList' do
        subject

        expect(page).to have_text(/Certificate Details/i)
        expect(page).to have_text('TNAuthList:')
        expect(page).to have_text('SPC: 1234')
      end
    end
  end
end
