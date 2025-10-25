# frozen_string_literal: true

RSpec.describe 'Customer Portal Access Profile' do
  include_context :login_as_admin

  describe 'create' do
    subject { click_on('Create Customer portal access profile') }

    context 'when name is blank' do
      before { visit new_customer_portal_access_profile_path }

      it 'should return validation error' do
        subject

        expect(page).to have_form_error("can't be blank", field: 'Name')
      end
    end
  end
end
