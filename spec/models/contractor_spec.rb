# frozen_string_literal: true

# == Schema Information
#
# Table name: contractors
#
#  id                 :integer(4)       not null, primary key
#  address            :string
#  customer           :boolean          not null
#  description        :string
#  enabled            :boolean          not null
#  name               :string           not null
#  phones             :string
#  vendor             :boolean          not null
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

    context 'when contractor has RateManagement Pricelist Items' do
      let(:contractor) { FactoryBot.create(:vendor) }
      let(:another_vendor) { FactoryBot.create(:vendor) }
      let!(:project) { FactoryBot.create(:rate_management_project, :filled, vendor: another_vendor) }
      let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, project: project) }
      let!(:pricelits_items) { FactoryBot.create_list(:rate_management_pricelist_item, 3, pricelist: pricelist, vendor: contractor) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist.id}"
        expect(contractor.errors.to_a).to contain_exactly error_message

        expect(Contractor).to be_exists(contractor.id)
      end

      context 'when pricelist applied' do
        let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, :applied, project: project) }

        it 'should raise validation error' do
          expect { subject }.to change { Contractor.count }.by(-1)

          pricelits_items.each do |item|
            expect(item.reload.vendor).to be_nil
          end
          expect(Contractor).not_to be_exists(contractor.id)
        end
      end
    end
  end
end
