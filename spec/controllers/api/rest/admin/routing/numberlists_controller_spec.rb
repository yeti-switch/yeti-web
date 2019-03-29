# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::Routing::NumberlistsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with ransack filters' do
    let(:factory) { :numberlist }

    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_datetime_field, :created_at
    it_behaves_like :jsonapi_filters_by_datetime_field, :updated_at
    it_behaves_like :jsonapi_filters_by_string_field, :default_src_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :default_src_rewrite_result
    it_behaves_like :jsonapi_filters_by_string_field, :default_dst_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :default_dst_rewrite_result
  end

  describe 'editable tag_action and tag_action_value' do
    include_examples :jsonapi_resource_with_multiple_tags do
      let(:resource_type) { 'numberlists' }
      let(:factory_name) { :numberlist }
    end
  end
end
