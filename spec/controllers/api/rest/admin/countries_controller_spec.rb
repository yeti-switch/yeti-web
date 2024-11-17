# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CountriesController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:countries) do
      System::NetworkPrefix.delete_all
      System::Country.delete_all
      [
        create(:country),
        create(:country, name: 'Canada', iso2: 'CA')
      ]
    end

    subject { get :index, params: { filter: filters } }
    let(:filters) do
      {}
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response should contain valid count of items' do
      subject
      expect(response_data.size).to eq(countries.size)
    end

    context 'filtering' do
      context 'by name' do
        let(:filters) do
          { 'name' => 'Ukraine' }
        end
        let!(:country) do
          create :country, name: 'Ukraine', iso2: 'UA'
        end
        it 'only desired countries should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => country.id.to_s
            )
          )
        end
      end

      context 'by iso2' do
        let(:filters) do
          { 'iso2' => 'UA' }
        end
        let!(:country) do
          create :country, name: 'Ukraine', iso2: 'UA'
        end
        it 'only desired countries should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => country.id.to_s
            )
          )
        end
      end
    end
  end

  describe 'GET show' do
    let!(:country) do
      System::Country.take!
    end

    subject do
      get :show, params: { id: country.id }
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response body should be valid' do
      subject
      expect(response_data).to match(
        hash_including(
          'id' => country.id.to_s,
          'type' => 'countries',
          'attributes' => {
            'name' => country.name,
            'iso2' => country.iso2
          }
        )
      )
    end
  end

  describe 'POST create' do
    subject do
      post :create, params: payload
    end
    let(:payload) do
      {
        data: {
          type: 'countries',
          attributes: {
            name: 'Wonderland',
            iso2: 'WL'
          }
        }
      }
    end

    it 'country should be created' do
      expect { subject }.to change { System::Country.count }.by(1)
    end
  end

  describe 'PATCH update' do
    subject do
      patch :update, params: { id: country.id, **payload }
    end
    let(:payload) do
      {
        data: {
          type: 'countries',
          id: country.id.to_s,
          attributes: {
            name: 'US'
          }
        }
      }
    end
    let(:country) do
      System::Country.take!
    end
    it 'country name should be changed' do
      expect { subject }.to change { country.reload.name }.from(country.name).to('US')
    end
  end

  describe 'DELETE delete' do
    subject do
      delete :destroy, params: { id: country.id }
    end
    let!(:country) do
      create(:country, name: 'Wonderland', iso2: 'WL')
    end

    it 'country should be deleted' do
      expect { subject }.to change { System::Country.count }.by(-1)
    end
  end
end
