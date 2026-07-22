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
    it 'renders the template against sample data' do
      visit preview_billing_notification_template_path(template)

      expect(page).to have_content('Low balance warning')
      expect(page).to have_content('Sample account')
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
