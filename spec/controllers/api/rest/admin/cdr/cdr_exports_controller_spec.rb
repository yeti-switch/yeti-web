# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Cdr::CdrExportsController, type: :controller do
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
      FactoryBot.create(:cdr_export, :completed)
    end

    it 'http code should be 204' do
      subject
      expect(response).to have_http_status(:no_content)
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
        'time_start_lteq' => '2018-03-01',
        'src_prefix_in_contains' => 'src_prefix_in_test',
        'src_prefix_routing_contains' => 'src_prefix_routing_test',
        'src_prefix_out_contains' => 'src_prefix_out_test',
        'dst_prefix_in_contains' => 'dst_prefix_in_test',
        'dst_prefix_routing_contains' => 'dst_prefix_routing_test',
        'dst_prefix_out_contains' => 'dst_prefix_out_test',
        'src_country_iso_eq' => country.iso2,
        'dst_country_iso_eq' => country.iso2,
        'routing_tag_ids_include' => 1,
        'routing_tag_ids_exclude' => 2,
        'routing_tag_ids_empty' => false
      }
    end
    let(:expected_filters) do
      filters.except('src_country_iso_eq', 'dst_country_iso_eq')
             .merge({ 'src_country_id_eq': country.id, 'dst_country_id_eq': country.id })
    end
    let(:country) { create(:country) }

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
        filters: CdrExport::FiltersModel.new(expected_filters)
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
            'filters' => CdrExport::FiltersModel.new(expected_filters).as_json,
            'created-at' => cdr_export.created_at.iso8601(3)
          }
        )
      )
    end

    it 'delayed job should be created' do
      expect { subject }.to have_enqueued_job(Worker::CdrExportJob)
    end

    context 'with non supporting filters' do
      let(:filters) { super().merge('unknown-filter' => '123') }

      include_examples :jsonapi_server_error
      include_examples :captures_error do
        let(:capture_error_context) do
          {
            user: {
              id: admin_user.id,
              username: admin_user.username,
              class: admin_user.class.name
            },
            tags: {
              action_name: 'create',
              controller_name: 'api/rest/admin/cdr/cdr_exports',
              request_id: nil
            },
            extra: {},
            request_env: be_present
          }
        end
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

    context 'with invalid dst iso country code' do
      let(:filters) do
        {
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'dst_country_iso_eq' => 'invalid'
        }
      end

      it 'validation error should be present' do
        subject
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['errors']).to match_array(
          hash_including(
            'detail' => 'invalid is not a valid value for dst_country_iso_eq.'
          )
        )
      end
    end

    context 'with invalid src iso country code' do
      let(:filters) do
        {
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'src_country_iso_eq' => 'invalid'
        }
      end

      it 'validation error should be present' do
        subject
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['errors']).to match_array(
          hash_including(
            'detail' => 'invalid is not a valid value for src_country_iso_eq.'
          )
        )
      end
    end
  end
end
