# frozen_string_literal: true

# to run this test you need to have config/ldap.yml file
#   cp -v config/ldap.yml.distr config/ldap.yml
# how to run:
#   CI_RUN_LDAP=true bundle exec rspec spec/features/sign_in_ldap_spec.rb
RSpec.describe 'sign in with ldap', :ldap do
  subject do
    visit new_admin_user_session_path
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    click_button 'Login'
  end

  let!(:admin_user) { nil }
  let(:username) { 'test_user' }
  let(:password) { 'test_pwd' }
  let(:ldap_is_valid) { true }
  let(:ldap_params) do
    { mail: ['user@test.com'], roles: nil }
  end
  let(:default_ldap_roles) { %w[default1 default2] }

  before do
    allow(YetiConfig).to receive(:default_ldap_roles).and_return(default_ldap_roles)
    # prevent not stubbed calls to LDAP
    stub_const('Devise::LDAP::Adapter', class_double('Devise::LDAP::Adapter'))
    # stub all needed calls
    allow(Devise::LDAP::Adapter).to receive(:valid_credentials?).with(username, password).and_return(ldap_is_valid)
    allow(Devise::LDAP::Adapter).to receive(:get_ldap_param).with(username, a_kind_of(String)) do |_, param|
      ldap_params.fetch(param.to_sym)
    end
    # to test ldap with different roles without patching roles.yml
    allow_any_instance_of(ActiveAdmin::PagePolicy).to receive(:show?).and_return(true)
  end

  shared_examples :signs_in_successfully do
    it 'signs in successfully' do
      subject
      expect(page).to have_current_path root_path
      expect(page).to have_flash_message 'Signed in successfully.', type: :notice
    end
  end

  shared_examples :does_not_sign_in do |message|
    it 'does not sign in' do
      subject
      expect(page).to have_current_path new_admin_user_session_path
      expect(page).to have_flash_message message, type: :alert
    end
  end

  shared_examples :creates_admin_user do
    let(:expected_attrs) { raise 'override let(:expected_attrs)' }

    it 'creates admin_user with correct roles' do
      expect {
        subject
        expect(page).to have_flash_message '', exact: false
      }.to change { AdminUser.count }.by(1)
      new_admin_user = AdminUser.last!
      expect(new_admin_user).to be_a(AdminUser)
      expect(new_admin_user).to have_attributes(
        allowed_ips: nil,
        enabled: true,
        per_page: {},
        remember_created_at: nil,
        reset_password_sent_at: nil,
        reset_password_token: nil,
        saved_filters: {},
        stateful_filters: false,
        visible_columns: {},
        encrypted_password: be_present,
        current_sign_in_at: be_present,
        current_sign_in_ip: '127.0.0.1',
        last_sign_in_at: be_present,
        last_sign_in_ip: '127.0.0.1',
        sign_in_count: 1,
        username:,
        **expected_attrs
      )
    end

    it 'creates billing_contact' do
      expect {
        subject
        expect(page).to have_flash_message '', exact: false
      }.to change { Billing::Contact.count }.by(1)
      new_admin_user = AdminUser.last!
      new_billing_contact = Billing::Contact.last!
      expect(new_billing_contact).to have_attributes(
        admin_user: new_admin_user,
        contractor_id: nil,
        notes: nil,
        created_at: be_present,
        updated_at: be_present,
        email: ldap_params[:mail].first
      )
    end
  end

  shared_examples :updates_admin_user do
    let(:expected_attrs) { raise 'override let(:expected_attrs)' }

    it 'updates admin_user with correct roles' do
      # reload cause we want created_at/updated_at to be the same
      old_attrs = admin_user.reload.attributes.symbolize_keys
      # capture values that should be moved/preserved across sign-in
      old_current_sign_in_at = old_attrs[:current_sign_in_at]
      old_current_sign_in_ip = old_attrs[:current_sign_in_ip]

      expect {
        subject
        expect(page).to have_flash_message '', exact: false
      }.not_to change { AdminUser.count }

      # remove time-sensitive and re-encrypted fields from strict equality
      base_attrs = old_attrs.except(:updated_at, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :encrypted_password, :sign_in_count)

      expect(admin_user.reload).to have_attributes(
        **base_attrs,
        updated_at: be_within(5.seconds).of(Time.current.utc),
        current_sign_in_at: be_within(5.seconds).of(Time.current.utc),
        current_sign_in_ip: '127.0.0.1',
        last_sign_in_at: old_current_sign_in_at,
        last_sign_in_ip: old_current_sign_in_ip,
        sign_in_count: old_attrs[:sign_in_count] + 1,
        encrypted_password: be_present, # it being re-encrypted on every login
        **expected_attrs
      )
    end

    it 'updates billing_contact' do
      # reload cause we want created_at/updated_at to be the same
      old_attrs = admin_user.billing_contact.reload.attributes.symbolize_keys
      expect {
        subject
        expect(page).to have_flash_message '', exact: false
      }.not_to change { Billing::Contact.count }
      expect(admin_user.billing_contact.reload).to have_attributes(
        **old_attrs,
        updated_at: be_within(5.seconds).of(Time.current),
        email: ldap_params[:mail].first
      )
    end
  end

  shared_examples :does_not_change_admin_user do
    let(:expected_roles) { raise 'override let(:expected_roles)' }

    it 'does not change admin_user' do
      expect {
        subject
        expect(page).to have_flash_message '', exact: false
      }.not_to change {
        [AdminUser.count, admin_user&.reload&.attributes]
      }
    end
  end

  context 'when admin_user does not exist in database' do
    include_examples :signs_in_successfully
    include_examples :creates_admin_user do
      let(:expected_attrs) { { roles: default_ldap_roles } }
    end

    context 'when admin_user has roles in ldap' do
      let(:ldap_params) do
        super().merge roles: %w[ldap1 ldap2]
      end

      include_examples :signs_in_successfully
      include_examples :creates_admin_user do
        let(:expected_attrs) { { roles: ldap_params[:roles] } }
      end
    end
  end

  context 'when admin_user exists in database' do
    before do
      admin_user.billing_contact.update!(email: ldap_params[:mail].first)
    end

    let(:admin_user) { create(:admin_user, admin_user_attrs) }
    let(:admin_user_attrs) do
      {
        username:,
        roles: %w[db1 db2],
        created_at: 2.days.ago,
        updated_at: 1.day.ago,
        current_sign_in_at: 1.hour.ago,
        current_sign_in_ip: '127.0.0.2',
        last_sign_in_at: 2.hours.ago,
        last_sign_in_ip: '127.0.0.3',
        sign_in_count: 3,
        billing_contact: Billing::Contact.new(billing_contact_attrs)
      }
    end
    let(:billing_contact_attrs) do
      { email: ldap_params[:mail].first }
    end

    include_examples :signs_in_successfully
    include_examples :updates_admin_user do
      let(:expected_attrs) { { roles: admin_user_attrs[:roles] } }
    end

    context 'when billing_contact has another mail' do
      let(:billing_contact_attrs) do
        { email: 'old@mail.com' }
      end

      include_examples :signs_in_successfully
      include_examples :updates_admin_user do
        let(:expected_attrs) { { roles: admin_user_attrs[:roles] } }
      end
    end

    context 'when admin_user has roles in ldap' do
      let(:ldap_params) do
        super().merge roles: %w[ldap1 ldap2]
      end

      include_examples :signs_in_successfully
      include_examples :updates_admin_user do
        let(:expected_attrs) { { roles: ldap_params[:roles] } }
      end
    end

    context 'when allowed_ips are filled with not match ip' do
      let(:admin_user_attrs) do
        super().merge allowed_ips: ['192.168.1.123']
      end

      include_examples :does_not_change_admin_user
      include_examples :does_not_sign_in, 'Your IP address is not allowed.'
    end

    context 'when allowed_ips are filled with match ip' do
      let(:admin_user_attrs) do
        super().merge allowed_ips: ['127.0.0.0/24']
      end

      include_examples :signs_in_successfully
      include_examples :updates_admin_user do
        let(:expected_attrs) { { roles: %w[db1 db2] } }
      end
    end
  end

  context 'with incorrect username or password' do
    let(:ldap_is_valid) { false }

    include_examples :does_not_change_admin_user
    include_examples :does_not_sign_in, 'Invalid email or password.'
  end
end
