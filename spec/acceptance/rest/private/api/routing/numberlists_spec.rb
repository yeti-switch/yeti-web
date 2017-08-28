require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Numberlist' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'routing/numberlists' }

  get '/api/rest/private/routing/numberlists' do
    before { create_list(:numberlist, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/routing/numberlists/:id' do
    let(:id) { create(:numberlist).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

end
