# frozen_string_literal: true

RSpec.describe 'Equipment STIR/SHAKEN trusted certificates' do
  include_context :login_as_admin

  let!(:trusted_certificate) { create(:stir_shaken_trusted_certificate, :with_certificate) }
  let!(:trusted_certificate_with_tn) { create(:stir_shaken_trusted_certificate, :with_tn_auth_list) }
  let!(:trusted_certificate_chain) { create(:stir_shaken_trusted_certificate, :with_certificate_chain) }

  describe 'index' do
    subject do
      visit '/equipment_stir_shaken_trusted_certificates'
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

    it 'displays certificate chain details' do
      subject

      expect(page).to have_table_cell(column: 'Certificate Details', text: 'Certificate #1')
      expect(page).to have_table_cell(column: 'Certificate Details', text: 'Certificate #2')
    end
  end

  describe 'show' do
    context 'certificate without TNAuthList' do
      subject do
        visit "/equipment_stir_shaken_trusted_certificates/#{trusted_certificate.id}"
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
        visit "/equipment_stir_shaken_trusted_certificates/#{trusted_certificate_with_tn.id}"
      end

      it 'displays certificate details with TNAuthList' do
        subject

        expect(page).to have_text(/Certificate Details/i)
        expect(page).to have_text('TNAuthList:')
        expect(page).to have_text('SPC: 1234')
      end
    end

    context 'certificate chain' do
      subject do
        visit "/equipment_stir_shaken_trusted_certificates/#{trusted_certificate_chain.id}"
      end

      it 'displays details for all certificates in chain' do
        subject

        expect(page).to have_text(/Certificate Details/i)
        expect(page).to have_text('Certificate #1')
        expect(page).to have_text('Subject: CN=Test SHAKEN')
        expect(page).to have_text('Certificate #2')
        expect(page).to have_text('Subject: CN=Test CA')
      end
    end
  end
end
