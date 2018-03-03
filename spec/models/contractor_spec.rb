# == Schema Information
#
# Table name: contractors
#
#  id                 :integer          not null, primary key
#  name               :string
#  enabled            :boolean
#  vendor             :boolean
#  customer           :boolean
#  description        :string
#  address            :string
#  phones             :string
#  smtp_connection_id :integer
#  external_id        :integer
#

require 'spec_helper'

describe Contractor, type: :model do

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
