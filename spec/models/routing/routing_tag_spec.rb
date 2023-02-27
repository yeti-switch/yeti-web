# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_tags
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routing_tags_name_key  (name) UNIQUE
#

RSpec.describe Routing::RoutingTag, type: :model do
  context 'validators' do
    context 'name' do
      it { is_expected.not_to allow_value(Routing::RoutingTag::NOT_TAGGED, 'NOT TAGGED').for(:name) }
      it { is_expected.not_to allow_value(Routing::RoutingTag::ANY_TAG, 'ANY TAG').for(:name) }

      it { is_expected.not_to allow_value('UA_CLI ').for(:name) }
      it { is_expected.not_to allow_value(' UA_CLI').for(:name) }
      it { is_expected.not_to allow_value('UA,CLI').for(:name) }

      it { is_expected.to allow_value('UA_CLI').for(:name) }
      it { is_expected.to allow_value('UA_C LI').for(:name) }

      context 'with same name' do
        before { FactoryBot.create(:routing_tag, name: 'didww1') }

        it { is_expected.not_to allow_value('didww1', 'Didww1', 'DIDWW1', 'DiDwW1').for(:name) }
      end
    end
  end

  context '#destroy' do
    let(:tag) do
      create(:routing_tag)
    end

    let(:tag_values) do
      # put subject tag is in the middle, to make test more extensive
      [create(:routing_tag).id, tag.id, create(:routing_tag).id]
    end

    subject do
      tag.destroy!
    end

    shared_examples :tag_can_not_be_destoryed do
      it 'should raise error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      it 'tag is not destoryed' do
        expect do
          subject
        rescue StandardError
          true
        end.not_to change { described_class.count }
      end
    end

    context 'when Tag was not used in any other resources' do
      it 'destroy tag successfully' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when Tag has CustomersAuth' do
      before do
        create(:customers_auth, tag_action_value: tag_values)
      end

      include_examples :tag_can_not_be_destoryed
    end

    context 'when Tag has Numberlist' do
      before do
        create(:numberlist, tag_action_value: tag_values)
      end

      include_examples :tag_can_not_be_destoryed
    end

    context 'when Tag has NumberlistItem' do
      before do
        create(:numberlist_item, tag_action_value: tag_values)
      end

      include_examples :tag_can_not_be_destoryed
    end

    context 'when Tag has RoutingTagDetectionRule' do
      before do
        create(:routing_tag_detection_rule,
               tag_action_value: tag_values)
      end

      include_examples :tag_can_not_be_destoryed
    end

    context 'when Tag has Dialpeer' do
      before do
        create(:dialpeer, routing_tag_ids: tag_values)
      end

      include_examples :tag_can_not_be_destoryed
    end

    context 'when Tag has Destination' do
      before do
        create(:destination, routing_tag_ids: tag_values)
      end

      include_examples :tag_can_not_be_destoryed
    end

    context 'when Tag is linked to RateManagement Project' do
      let!(:projects) { FactoryBot.create_list(:rate_management_project, 3, :filled, routing_tag_ids: [tag.id]) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to Rate Management Project(s) ##{projects.map(&:id).join(', #')}"
        expect(tag.errors.to_a).to contain_exactly error_message

        expect(Routing::RoutingTag).to be_exists(tag.id)
      end
    end

    context 'when Tag is linked to RateManagement Pricelist Item' do
      let(:new_tag) { FactoryBot.create(:routing_tag) }
      let(:project) { FactoryBot.create(:rate_management_project, :filled, routing_tag_ids: [new_tag.id]) }
      let!(:pricelists) do
        FactoryBot.create_list(:rate_management_pricelist, 2, pricelist_state, project: project)
      end
      let(:pricelist_state) { :new }
      let!(:pricelist_items) do
        [
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[0], routing_tag_ids: [tag.id]),
          FactoryBot.create_list(:rate_management_pricelist_item, 2, :filed_from_project, pricelist: pricelists[1], routing_tag_ids: [tag.id])
        ].flatten
      end

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
        expect(tag.errors.to_a).to contain_exactly error_message

        expect(Routing::RoutingTag).to be_exists(tag.id)
      end

      context 'when pricelist has dialpeers_detected state' do
        let(:pricelist_state) { :dialpeers_detected }

        it 'should raise validation error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

          error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
          expect(tag.errors.to_a).to contain_exactly error_message

          expect(Routing::RoutingTag).to be_exists(tag.id)
        end
      end

      context 'when pricelist has applied state' do
        let(:pricelist_state) { :applied }

        it 'should raise validation error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

          error_message = "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelists.map(&:id).join(', #')}"
          expect(tag.errors.to_a).to contain_exactly error_message

          expect(Routing::RoutingTag).to be_exists(tag.id)
        end
      end
    end

    context 'when Account is linked to RateManagement Project and Pricelist Items' do
      let!(:project) { FactoryBot.create(:rate_management_project, :filled, routing_tag_ids: [tag.id]) }
      let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, project: project, items_qty: 1) }

      it 'should raise validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)

        error_messages = [
          "Can't be deleted because linked to Rate Management Project(s) ##{project.id}",
          "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist.id}"
        ]
        expect(tag.errors).to contain_exactly *error_messages

        expect(Routing::RoutingTag).to be_exists(tag.id)
      end
    end
  end
end
