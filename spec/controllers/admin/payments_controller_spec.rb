RSpec.describe Admin::PaymentsController, type: :controller do

  let(:account) { create(:account) }

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: {sub: user.id}).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'DELETE destroy' do
    it 'returns error status code' do
      expect(response).to have_http_status(:error)
    end
  end
end
