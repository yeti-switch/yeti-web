# frozen_string_literal: true

require 'spec_helper'

xdescribe Api::Rest::Admin::DialpeerNextRatesController do
  describe 'GET index' do
    subject { get :index, params: { dialpeer_id: 1, format: :json } }

    it 'should return status 200' do
      subject
      expect(response.status).to eq 200
    end

    it 'should return correct body' do
      subject
      expect(response.body).to eq ''
    end
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :dialpeer_next_rate }

    it_behaves_like :jsonapi_filters_by_number_field, :next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :initial_rate
    it_behaves_like :jsonapi_filters_by_number_field, :initial_interval
    it_behaves_like :jsonapi_filters_by_number_field, :next_interval
    it_behaves_like :jsonapi_filters_by_number_field, :connect_fee
    #it_behaves_like :jsonapi_filters_by_datetime_field, :apply_time
    it_behaves_like :jsonapi_filters_by_boolean_field, :applied
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
  end
end
