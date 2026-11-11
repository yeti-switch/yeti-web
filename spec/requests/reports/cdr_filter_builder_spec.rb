# frozen_string_literal: true

RSpec.describe 'CDR report filter builder', type: :request do
  include_context :login_as_admin

  shared_examples :renders_the_filter_builder do
    it 'renders the structured filter builder with column metadata' do
      get path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('cdr-filter-builder')
      # the result is shown back as a live hint and stored in a hidden field
      expect(response.body).to include('cdr-filter-preview')
      expect(response.body).to match(/<input[^>]*type="hidden"[^>]*filter/)
      # column metadata is embedded for the JS widget
      expect(response.body).to include('customer_id')
      expect(response.body).to include('/contractors/search')
    end
  end

  describe 'GET /custom_cdrs/new' do
    let(:path) { new_custom_cdr_path }

    include_examples :renders_the_filter_builder
  end

  describe 'GET new interval cdr report' do
    let(:path) { new_report_interval_cdr_path }

    include_examples :renders_the_filter_builder
  end
end
