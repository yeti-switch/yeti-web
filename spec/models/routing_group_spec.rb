# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_groups
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routing_groups_name_unique  (name) UNIQUE
#
RSpec.describe Routing::RoutingGroup do
  describe '#destroy!' do
    subject { routing_group.destroy! }
    let!(:routing_group) { FactoryBot.create(:routing_group) }

    context 'when RoutingGroup is linked to RateManagement Project' do
      let!(:projects) { FactoryBot.create_list(:rate_management_project, 3, :filled, routing_group: routing_group) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to Rate Management Project(s) ##{projects.map(&:id).join(', #')}"
        expect(routing_group.errors.to_a).to contain_exactly error_message

        expect(Routing::RoutingGroup).to be_exists(routing_group.id)
      end
    end

    context 'when RoutingGroup is linked to RateManagement Pricelist Item' do
      let(:new_routing_group) { FactoryBot.create(:routing_group) }
      let(:project) { FactoryBot.create(:rate_management_project, :filled, routing_group: new_routing_group) }
      let!(:pricelists) do
        FactoryBot.create_list(:rate_management_pricelist, 2, pricelist_state, project: project)
      end
      let(:pricelist_state) { :new }
      let!(:pricelist_items) do
        [
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[0], routing_group: routing_group),
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[1], routing_group: routing_group)
        ].flatten
      end

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
        expect(routing_group.errors.to_a).to contain_exactly error_message

        expect(Routing::RoutingGroup).to be_exists(routing_group.id)
      end

      context 'when pricelist has dialpeers_detected state' do
        let(:pricelist_state) { :dialpeers_detected }

        it 'should raise validation error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

          error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
          expect(routing_group.errors.to_a).to contain_exactly error_message

          expect(Routing::RoutingGroup).to be_exists(routing_group.id)
        end
      end

      context 'when pricelist has applied state' do
        let(:pricelist_state) { :applied }

        it 'should delete routing_group' do
          expect { subject }.not_to raise_error
          expect(Routing::RoutingGroup).not_to be_exists(routing_group.id)

          pricelist_items.each do |item|
            expect(item.reload.routing_group_id).to be_nil
          end
        end
      end
    end
  end
end
