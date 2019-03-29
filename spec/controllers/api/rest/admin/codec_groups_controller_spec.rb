# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::Rest::Admin::CodecGroupsController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :codec_group }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end
end
