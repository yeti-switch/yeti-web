RSpec.shared_context :login_as_admin do

  let(:admin_user) { create :admin_user }

  before do
    login_as(admin_user, scope: :admin_user)
  end
end
