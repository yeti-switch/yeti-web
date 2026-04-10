# frozen_string_literal: true

# Regression guard for the OIDC JIT-provisioning path. yeti-web stores
# admin_user.email on billing_contact via attr_writer :email + an after_save
# hook on AdminUser. The activeadmin-oidc gem is unaware of this and just
# calls admin_user.email = ... followed by save. This spec proves that
# pipeline still wires the billing_contact correctly.
#
# Runs in the default DB suite via the factory (which supplies the password
# required by :database_authenticatable). The code path under test — the
# attr_writer + after_save hook — is shared between modes, so validating it
# in DB mode covers the OIDC provisioner behaviour too.
RSpec.describe AdminUser, 'email → billing_contact hook' do
  it 'persists the email onto billing_contact on create' do
    user = build(:admin_user, username: 'oidc-alice')
    user.email = 'alice@test.com'
    user.save!

    reloaded = described_class.find_by!(username: 'oidc-alice')
    expect(reloaded.billing_contact).to be_present
    expect(reloaded.billing_contact.email).to eq('alice@test.com')
  end

  it 'updates billing_contact email on subsequent save' do
    user = create(:admin_user, username: 'oidc-bob', email: 'bob@old.com')
    expect(user.reload.billing_contact.email).to eq('bob@old.com')

    user.email = 'bob@new.com'
    user.save!
    expect(user.reload.billing_contact.email).to eq('bob@new.com')
  end
end
