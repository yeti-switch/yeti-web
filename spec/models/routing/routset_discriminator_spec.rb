# frozen_string_literal: true

RSpec.describe Routing::RoutesetDiscriminator do
  describe '#destroy!' do
    subject { routeset_discriminator.destroy! }
    let!(:routeset_discriminator) { FactoryBot.create(:routeset_discriminator) }

    context 'when RoutesetDiscriminator is linked to Dialpeer' do
      before { FactoryBot.create(:dialpeer, routeset_discriminator: routeset_discriminator) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        expect(routeset_discriminator.errors.to_a).to contain_exactly 'Cannot delete record because dependent dialpeers exist'

        expect(Routing::RoutesetDiscriminator).to be_exists(routeset_discriminator.id)
      end
    end

    context 'when RoutesetDiscriminator is linked to RateManagement Project' do
      let!(:projects) { FactoryBot.create_list(:rate_management_project, 3, :filled, routeset_discriminator: routeset_discriminator) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to Rate Management Project(s) ##{projects.map(&:id).join(', #')}"
        expect(routeset_discriminator.errors.to_a).to contain_exactly error_message

        expect(Routing::RoutesetDiscriminator).to be_exists(routeset_discriminator.id)
      end
    end

    context 'when RoutesetDiscriminator is linked to RateManagement Pricelist Item' do
      let(:new_routeset_discriminator) { FactoryBot.create(:routeset_discriminator) }
      let(:project) { FactoryBot.create(:rate_management_project, :filled, routeset_discriminator: new_routeset_discriminator) }
      let!(:pricelists) do
        FactoryBot.create_list(:rate_management_pricelist, 2, pricelist_state, project: project)
      end
      let(:pricelist_state) { :new }
      let!(:pricelist_items) do
        [
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[0], routeset_discriminator: routeset_discriminator),
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[1], routeset_discriminator: routeset_discriminator)
        ].flatten
      end

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
        expect(routeset_discriminator.errors.to_a).to contain_exactly error_message

        expect(Routing::RoutesetDiscriminator).to be_exists(routeset_discriminator.id)
      end

      context 'when pricelist has dialpeers_detected state' do
        let(:pricelist_state) { :dialpeers_detected }

        it 'should raise validation error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

          error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
          expect(routeset_discriminator.errors.to_a).to contain_exactly error_message

          expect(Routing::RoutesetDiscriminator).to be_exists(routeset_discriminator.id)
        end
      end

      context 'when pricelist has applied state' do
        let(:pricelist_state) { :applied }

        it 'should delete routeset_discriminator' do
          expect { subject }.not_to raise_error
          expect(Routing::RoutesetDiscriminator).not_to be_exists(routeset_discriminator.id)

          pricelist_items.each do |item|
            expect(item.reload.routeset_discriminator_id).to be_nil
          end
        end
      end
    end

    context 'when RoutesetDiscriminator is linked to RateManagement Project and Pricelist Items' do
      let!(:project) { FactoryBot.create(:rate_management_project, :filled, routeset_discriminator: routeset_discriminator) }
      let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, project: project, items_qty: 1) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_messages = [
          "Can't be deleted because linked to Rate Management Project(s) ##{project.id}",
          "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist.id}"
        ]
        expect(routeset_discriminator.errors).to contain_exactly *error_messages

        expect(Routing::RoutesetDiscriminator).to be_exists(routeset_discriminator.id)
      end
    end
  end
end
