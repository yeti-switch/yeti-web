# frozen_string_literal: true

# The playground preview action (app/admin/billing/invoice_template_playground.rb).
RSpec.describe 'Invoice template playground preview', type: :request do
  include_context :login_as_admin

  let!(:contractor) { create(:vendor) }
  let!(:account) { create(:account, contractor: contractor) }
  let!(:invoice) { create(:invoice, account: account) }

  let(:params) do
    { invoice_id: invoice.id, template: '<p>{{ invoice.reference }}</p>', filename_template: filename_template }
  end

  # The test env keeps allow_forgery_protection on, so the preview POST needs a
  # token from a real session — take it from the page the way the browser does
  # (the editor reads the same meta tag) instead of weakening protection.
  def csrf_token
    get template_playground_path
    Nokogiri::HTML(response.body).at('meta[name="csrf-token"]')&.[]('content')
  end

  subject { post template_playground_preview_path, params: params, headers: { 'X-CSRF-Token' => csrf_token } }

  before { allow(YetiPdf::Client).to receive(:render_pdf) }

  context 'with a blank filename template' do
    let(:filename_template) { '' }

    # Blank is rejected locally: the column is NOT NULL and the model requires
    # it, so there is nothing worth asking yeti-pdf about.
    it 'responds with a validation error and does not call yeti-pdf' do
      subject
      expect(response.status).to eq(422)
      expect(response.body).to match(/Filename template must not be blank/)
      expect(YetiPdf::Client).not_to have_received(:render_pdf)
    end
  end

  context 'with a filename template' do
    let(:filename_template) { 'invoice-{{invoice.reference}}' }

    before do
      allow(YetiPdf::Client).to receive(:render_pdf)
        .and_return(YetiPdf::Client::Result.new('%PDF-bytes', 'invoice-INV-1'))
    end

    it 'renders the pdf and reports the rendered name' do
      subject
      expect(response.status).to eq(200)
      expect(response.body).to eq('%PDF-bytes')
      expect(response.headers['X-Rendered-Filename']).to eq('invoice-INV-1')
      expect(YetiPdf::Client).to have_received(:render_pdf)
        .with(hash_including(filename_template: filename_template))
    end
  end
end
