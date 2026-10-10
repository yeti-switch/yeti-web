# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ContactsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :contact }
    let(:json_api_request_query) { nil }

    describe 'by email' do
      include_context :ransack_filter_setup

      let!(:record_str) { create_record email: 'str@example.com' }
      let!(:record_string) { create_record email: 'string@example.com' }
      let!(:record_other) { create_record email: 'other@example.org' }

      it 'filters by email' do
        aggregate_failures do
          assert_filter 'email_start', 'str', includes: record_string, excludes: record_other
          assert_filter 'email_end', '.com', includes: record_string, excludes: record_other
          assert_filter 'email_cont', 'string', includes: record_string, excludes: record_other
          assert_filter 'email_eq', 'str@example.com', includes: record_str, excludes: record_string
          assert_filter 'email_not_eq', 'str@example.com', includes: record_string, excludes: record_str
          assert_filter 'email_in', 'str@example.com,x@example.com', includes: record_str, excludes: record_string
          assert_filter 'email_not_in', 'string@example.com,x@example.com', includes: record_str, excludes: record_string
          assert_filter 'email_cont_any', 'string,val', includes: record_string, excludes: record_other
        end
      end
    end

    it_behaves_like :jsonapi_filters_by_string_field, :notes
  end
end
