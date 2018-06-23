RSpec.resource 'Timezones' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'timezones' }

  get '/api/rest/admin/system/timezones' do

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/system/timezones/:id' do
    let(:id) { System::Timezone.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

end
