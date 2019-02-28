# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Admin::Cdr::CdrExportsController, type: :controller do
  let(:admin_user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: admin_user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: cdr_export.id } }
    let(:cdr_export) do
      FactoryGirl.create(:cdr_export, :completed)
    end

    it 'http code should be 204' do
      subject
      expect(response).to have_http_status(204)
    end

    it 'status should be changed to removed' do
      expect { subject }.to change { cdr_export.reload.status }.from(CdrExport::STATUS_COMPLETED).to(CdrExport::STATUS_DELETED)
    end

    it 'remove file job should be enqueued' do
      expect { subject }.to have_enqueued_job(Worker::RemoveCdrExportFileJob).with(cdr_export.id)
    end
  end

  describe 'POST create' do
    subject { post :create, params: payload }
    let(:payload) do
      {
        data: {
          type: 'cdr-exports',
          attributes: {
            fields: fields,
            filters: filters
          }
        }
      }
    end
    let(:fields) do
      [
        'success'
      ]
    end
    let(:filters) do
      {
        'time_start_gteq' => '2018-01-01',
        'time_start_lteq' => '2018-03-01'
      }
    end

    it 'http status should eq 201' do
      subject
      expect(response.status).to eq(201)
    end

    it 'CDR export should be created' do
      expect { subject }.to change { CdrExport.count }.by(1)
    end

    it 'created CDR export has valid attributes' do
      subject
      expect(CdrExport.last!).to have_attributes(
        status: CdrExport::STATUS_PENDING,
        fields: fields,
        filters: filters
      )
    end

    it 'response body should be valid' do
      subject
      cdr_export = CdrExport.last!
      expect(JSON.parse(response.body)['data']).to match(
        hash_including(
          'id' => cdr_export.id.to_s,
          'type' => 'cdr-exports',
          'attributes' => {
            'export-type' => 'Base',
            'callback-url' => nil,
            'status' => CdrExport::STATUS_PENDING,
            'fields' => fields,
            'filters' => filters,
            'created-at' => cdr_export.created_at.iso8601(3)
          }
        )
      )
    end

    it 'delayed job should be created' do
      expect { subject }.to have_enqueued_job(Worker::CdrExportJob)
    end

    context 'with non supporting filters' do
      let(:filters) do
        super().merge('unknown-filter' => '123')
      end
      it 'validation error should be present' do
        subject
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors']).to match_array(
          hash_including(
            'detail' => 'filters - unknown-filter not allowed'
          )
        )
      end
    end

    context 'with unknown fields' do
      let(:fields) do
        ['unknown_field']
      end
      it 'validation error should be present' do
        subject
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors']).to match_array(
          hash_including(
            'detail' => 'fields - unknown_field not allowed'
          )
        )
      end
    end
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :cdr_export }

    #it_behaves_like :jsonapi_filters_by_string_field, :fields   ARRAY
    #it_behaves_like :jsonapi_filters_by_json_field, :filters
    it_behaves_like :jsonapi_filters_by_string_field, :status
    #it_behaves_like :jsonapi_filters_by_datetime_field, :created_at
    it_behaves_like :jsonapi_filters_by_string_field, :callback_url
  end
end
