# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id                     :integer(4)       not null, primary key
#  max_rerouting_attempts :integer(2)       default(10), not null
#  name                   :string           not null
#  prefer_same_pop        :boolean          default(TRUE), not null
#  balancing_mode_id      :integer(2)       default(1), not null
#  vendor_id              :integer(4)       not null
#
# Indexes
#
#  gateway_groups_name_key       (name) UNIQUE
#  gateway_groups_vendor_id_idx  (vendor_id)
#
# Foreign Keys
#
#  gateway_groups_contractor_id_fkey  (vendor_id => contractors.id)
#
RSpec.describe GatewayGroup do
  describe '#destroy!' do
    subject { gateway_group.destroy! }
    let(:gateway_group) { FactoryBot.create(:gateway_group) }

    context 'when GatewayGroup is linked to RateManagement Project' do
      let!(:projects) do
        FactoryBot.create_list(:rate_management_project, 3, :filled, vendor: gateway_group.vendor, gateway: nil, gateway_group: gateway_group)
      end

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to Rate Management Project(s) ##{projects.map(&:id).join(', #')}"
        expect(gateway_group.errors.to_a).to contain_exactly error_message

        expect(GatewayGroup).to be_exists(gateway_group.id)
      end
    end

    context 'when GatewayGroup is linked to RateManagement Pricelist Item' do
      let(:new_gateway_group) { FactoryBot.create(:gateway_group) }
      let(:project) { FactoryBot.create(:rate_management_project, :filled, vendor: new_gateway_group.vendor, gateway: nil, gateway_group: new_gateway_group) }
      let!(:pricelists) do
        FactoryBot.create_list(:rate_management_pricelist, 2, pricelist_state, project: project)
      end
      let(:pricelist_state) { :new }
      let!(:pricelist_items) do
        [
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[0], gateway_group: gateway_group),
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[1], gateway_group: gateway_group)
        ].flatten
      end

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
        expect(gateway_group.errors.to_a).to contain_exactly error_message

        expect(GatewayGroup).to be_exists(gateway_group.id)
      end

      context 'when pricelist has dialpeers_detected state' do
        let(:pricelist_state) { :dialpeers_detected }

        it 'should raise validation error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

          error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
          expect(gateway_group.errors.to_a).to contain_exactly error_message

          expect(GatewayGroup).to be_exists(gateway_group.id)
        end
      end

      context 'when pricelist has applied state' do
        let(:pricelist_state) { :applied }

        it 'should delete gateway_group' do
          expect { subject }.not_to raise_error
          expect(GatewayGroup).not_to be_exists(gateway_group.id)

          pricelist_items.each do |item|
            expect(item.reload.gateway_group_id).to be_nil
          end
        end
      end
    end

    context 'when GatewayGroup is linked to RateManagement Project and Pricelist Items' do
      let!(:project) do
        FactoryBot.create(:rate_management_project, :filled, vendor: gateway_group.vendor, gateway: nil, gateway_group: gateway_group)
      end
      let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, project: project, items_qty: 1) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_messages = [
          "Can't be deleted because linked to Rate Management Project(s) ##{project.id}",
          "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist.id}"
        ]
        expect(gateway_group.errors).to contain_exactly *error_messages

        expect(GatewayGroup).to be_exists(gateway_group.id)
      end
    end
  end
end
