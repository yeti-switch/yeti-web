# frozen_string_literal: true

RSpec.describe 'Show Log Email log', type: :feature do
  include_context :login_as_admin

  # The message body can be admin-authored HTML (notification templates), so the
  # email log page must not let a stored script run in the viewing admin's
  # session. It is rendered inside a script-less sandboxed iframe instead.
  context 'when the message body contains script' do
    let(:email_log) do
      create(:email_log, msg: '<div>hello body</div><script>alert(1)</script>')
    end

    before { visit log_email_log_path(email_log) }

    it 'renders the body in a sandboxed iframe' do
      iframe = page.first('iframe')
      expect(iframe).to be_present
      expect(iframe['sandbox']).to eq('')
    end

    it 'escapes the body into srcdoc rather than the page DOM' do
      expect(page.body).to include('srcdoc=')
      expect(page.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
      expect(page.body).not_to include('<script>alert(1)</script>')
    end
  end

  context 'when the message body is blank' do
    let(:email_log) { create(:email_log, msg: nil) }

    it 'shows the page without an email body iframe' do
      visit log_email_log_path(email_log)
      expect(page).to have_content(email_log.subject)
      expect(page).to have_no_css('iframe')
    end
  end
end
