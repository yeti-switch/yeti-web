# frozen_string_literal: true

RSpec.describe 'Unknown paths', type: :request do
  it 'responds to XHR with an empty 404' do
    get '/SDK/webLanguage', headers: { 'X-Requested-With' => 'XMLHttpRequest', 'Accept' => '*/*' }
    expect(response).to have_http_status(:not_found)
    expect(response.body).to be_empty
  end

  it 'renders the HTML 404 page' do
    get '/SDK/webLanguage'
    expect(response).to have_http_status(:not_found)
    expect(response.media_type).to eq('text/html')
    expect(response.body).to include('NOT FOUND')
  end

  it 'responds to images with a plain 404' do
    get '/missing.png'
    expect(response).to have_http_status(:not_found)
    expect(response.body).to eq('404 Yeti Not Found')
  end
end
