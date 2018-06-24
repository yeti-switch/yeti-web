RSpec.xdescribe Api::Rest::Admin::DialpeerNextRatesController do

  describe 'GET index' do
    subject { get :index, params: {dialpeer_id: 1, format: :json}  }

    it 'should return status 200' do
      subject
      expect(response.status).to eq 200
    end

    it 'should return correct body' do
      subject
      expect(response.body).to eq ''
    end

  end

end
