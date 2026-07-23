# frozen_string_literal: true

RSpec.describe 'Manage notification templates' do
  include_context :login_as_admin

  let(:event) { System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED }
  let(:template) { Billing::NotificationTemplate.find_by!(event: event) }

  describe 'index' do
    before { visit billing_notification_templates_path }

    it 'lists the seeded templates' do
      expect(page).to have_content(event)
    end

    it 'offers no way to create one, because rows are seeded and fixed' do
      expect(page).not_to have_link('New Notification Template')
    end
  end

  describe 'show' do
    before { visit billing_notification_template_path(template) }

    it 'documents the variables available to the template' do
      expect(page).to have_content('account.balance')
      expect(page).to have_content('threshold.low')
    end

    it 'offers no delete action' do
      expect(page).not_to have_link('Delete')
    end
  end

  describe 'edit' do
    before { visit edit_billing_notification_template_path(template) }

    it 'saves a valid template' do
      fill_in 'billing_notification_template[body]', with: 'Balance is {{ account.balance }}'
      click_button 'Update Notification template'

      expect(template.reload.body).to eq('Balance is {{ account.balance }}')
    end

    it 'rejects a template referencing an unavailable variable' do
      original = template.body
      fill_in 'billing_notification_template[body]', with: '{{ account.secret_column }}'
      click_button 'Update Notification template'

      expect(page).to have_content('unknown variable')
      expect(template.reload.body).to eq(original)
    end
  end

  describe 'preview' do
    it 'renders the template against sample data inside a sandboxed frame' do
      visit preview_billing_notification_template_path(template)

      iframe = page.first('iframe')
      expect(iframe['sandbox']).to eq('')
      # content lives in the frame's srcdoc, matching the delivered email
      expect(page.body).to include('Low balance warning')
      expect(page.body).to include('Sample account')
    end

    # The preview renders admin-authored HTML verbatim, so a template author must
    # not be able to run script in the browser of an admin holding a higher role.
    context 'when the stored template contains script' do
      before do
        template.update_column(:body, '<p>hi</p><script>alert(1)</script>')
        visit preview_billing_notification_template_path(template)
      end

      it 'renders the body in a script-less sandboxed iframe' do
        expect(page.first('iframe')['sandbox']).to eq('')
      end

      it 'escapes the body into srcdoc rather than the page DOM' do
        expect(page.body).to include('srcdoc=')
        expect(page.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
        expect(page.body).not_to include('<script>alert(1)</script>')
      end
    end
  end

  describe 'destroy' do
    it 'has no delete route, because rows are seeded and fixed' do
      expect do
        Rails.application.routes.recognize_path(
          billing_notification_template_path(template), method: :delete
        )
      end.to raise_error(ActionController::RoutingError)
    end
  end
end
