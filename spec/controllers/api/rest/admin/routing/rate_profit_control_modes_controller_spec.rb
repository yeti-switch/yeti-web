# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::Routing::RateProfitControlModesController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with ransack filters' do
    let(:factory) { :rate_profit_control_mode }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end
end
