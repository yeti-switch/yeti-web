# frozen_string_literal: true

# == Schema Information
#
# Table name: contractors
# Database name: primary
#
#  id                 :integer(4)       not null, primary key
#  address            :string
#  customer           :boolean          not null
#  description        :string
#  enabled            :boolean          not null
#  name               :string           not null
#  phones             :string
#  uuid               :uuid             not null
#  vendor             :boolean          not null
#  external_id        :bigint(8)
#  smtp_connection_id :integer(4)
#
# Indexes
#
#  contractors_external_id_key  (external_id) UNIQUE
#  contractors_name_unique      (name) UNIQUE
#  contractors_uuid_key         (uuid) UNIQUE
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
      let!(:vendor_traffic_scheduler) { FactoryBot.create(:vendor_traffic_scheduler, vendor: contractor) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist.id}"
        expect(contractor.errors.to_a).to contain_exactly error_message

        expect(Contractor).to be_exists(contractor.id)
        expect(Report::VendorTrafficScheduler).to be_exists(vendor_traffic_scheduler.id)
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

    context 'when contractor has report schedulers' do
      let(:contractor) { FactoryBot.create(:customer, vendor: true) }
      let(:other_customer) { FactoryBot.create(:customer, vendor: true) }

      before do
        FactoryBot.create(:customer_traffic_scheduler, customer: contractor)
        FactoryBot.create(:vendor_traffic_scheduler, vendor: contractor)
        FactoryBot.create(:custom_cdr_scheduler, customer: contractor)
        FactoryBot.create(:customer_traffic_scheduler, customer: other_customer)
        FactoryBot.create(:vendor_traffic_scheduler, vendor: other_customer)
        FactoryBot.create(:custom_cdr_scheduler, customer: other_customer)
        FactoryBot.create(:custom_cdr_scheduler)
      end

      it 'removes its report schedulers only' do
        expect { subject }.to change { Contractor.count }.by(-1)

        expect(Report::CustomerTrafficScheduler.pluck(:customer_id)).to eq([other_customer.id])
        expect(Report::VendorTrafficScheduler.pluck(:vendor_id)).to eq([other_customer.id])
        expect(Report::CustomCdrScheduler.pluck(:customer_id)).to contain_exactly(other_customer.id, nil)
      end

      context 'when another report scheduler sends to its contacts' do
        let!(:contact) { FactoryBot.create(:contact, contractor: contractor) }
        let!(:other_contact) { FactoryBot.create(:contact, contractor: other_customer) }
        let!(:interval_cdr_scheduler) do
          FactoryBot.create(:interval_cdr_scheduler, send_to: [contact.id, other_contact.id])
        end

        it 'removes its contacts from that scheduler' do
          expect { subject }.to change { Billing::Contact.count }.by(-1)
          expect(interval_cdr_scheduler.reload.send_to).to eq([other_contact.id])
        end
      end

      context 'when database rejects contractor deletion' do
        let!(:contact) { FactoryBot.create(:contact, contractor: contractor) }
        let!(:interval_cdr_scheduler) { FactoryBot.create(:interval_cdr_scheduler, send_to: [contact.id]) }

        before do
          allow(contractor).to receive(:_delete_row).and_raise(ActiveRecord::InvalidForeignKey, 'dialpeers_vendor_id_fkey')
        end

        it 'keeps report schedulers and their recipients' do
          expect { subject }.to raise_error(ActiveRecord::InvalidForeignKey)

          expect(Contractor).to be_exists(contractor.id)
          expect(Billing::Contact).to be_exists(contact.id)
          expect(Report::CustomerTrafficScheduler.count).to eq(2)
          expect(Report::VendorTrafficScheduler.count).to eq(2)
          expect(Report::CustomCdrScheduler.count).to eq(3)
          expect(interval_cdr_scheduler.reload.send_to).to eq([contact.id])
        end
      end

      context 'when contractor has accounts' do
        before { FactoryBot.create(:account, contractor: contractor) }

        it 'keeps its report schedulers' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

          expect(Contractor).to be_exists(contractor.id)
          expect(Report::CustomerTrafficScheduler.count).to eq(2)
          expect(Report::VendorTrafficScheduler.count).to eq(2)
          expect(Report::CustomCdrScheduler.count).to eq(3)
        end
      end
    end
  end

  context '#update' do
    subject do
      contractor.update!(attributes)
    end

    let(:contractor) { FactoryBot.create(:customer, vendor: true) }

    before do
      FactoryBot.create(:customer_traffic_scheduler, customer: contractor)
      FactoryBot.create(:vendor_traffic_scheduler, vendor: contractor)
      FactoryBot.create(:custom_cdr_scheduler, customer: contractor)
    end

    context 'when customer flag is removed' do
      let(:attributes) { { customer: false } }

      it 'removes Customer Traffic Report Schedulers only' do
        expect { subject }.to change { Report::CustomerTrafficScheduler.count }.by(-1)
        expect(Report::VendorTrafficScheduler.count).to eq(1)
        expect(Report::CustomCdrScheduler.count).to eq(1)
      end
    end

    context 'when vendor flag is removed' do
      let(:attributes) { { vendor: false } }

      it 'removes Vendor Traffic Report Schedulers only' do
        expect { subject }.to change { Report::VendorTrafficScheduler.count }.by(-1)
        expect(Report::CustomerTrafficScheduler.count).to eq(1)
        expect(Report::CustomCdrScheduler.count).to eq(1)
      end
    end

    context 'when flags are not changed' do
      let(:attributes) { { name: 'renamed' } }

      it 'keeps report schedulers' do
        subject
        expect(Report::CustomerTrafficScheduler.count).to eq(1)
        expect(Report::VendorTrafficScheduler.count).to eq(1)
        expect(Report::CustomCdrScheduler.count).to eq(1)
      end
    end
  end
end
