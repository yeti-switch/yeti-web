# frozen_string_literal: true

# == Schema Information
#
# Table name: contractors
#
#  id                 :integer(4)       not null, primary key
#  address            :string
#  customer           :boolean
#  description        :string
#  enabled            :boolean
#  name               :string
#  phones             :string
#  vendor             :boolean
#  external_id        :bigint(8)
#  smtp_connection_id :integer(4)
#
# Indexes
#
#  contractors_external_id_key  (external_id) UNIQUE
#  contractors_name_unique      (name) UNIQUE
#
# Foreign Keys
#
#  contractors_smtp_connection_id_fkey  (smtp_connection_id => smtp_connections.id)
#

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
