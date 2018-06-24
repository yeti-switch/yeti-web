RSpec.describe Contractor, type: :model do

  let!(:contractor) {}

  context '#destroy' do

    subject do
      contractor.destroy!
    end

    context 'when Contractor is linked from ApiAccess' do
      let!(:contractor) { api_access.customer }
      let(:api_access) { create(:api_access) }

      it 'removes all related ApiAccess' do
        expect { subject }.to change { System::ApiAccess.count }.by(-1)
      end
    end

  end

end
