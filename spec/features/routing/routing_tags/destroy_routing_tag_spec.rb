# frozen_string_literal: true

RSpec.describe 'Destroy Routing Routing Tag', type: :feature, js: true do
  include_context :login_as_admin

  let!(:record) { FactoryBot.create(:routing_tag) }

  shared_examples :tag_can_not_be_destoryed do |message|
    it 'should not be destroyed' do
      expect do
        subject

        expect(page).to have_flash_message(message, type: :alert)
      end.not_to change { Routing::RoutingTag.count }
    end
  end

  subject do
    visit routing_routing_tag_path(record)

    accept_confirm do
      click_on 'Delete Routing Routing Tag'
    end
  end

  it 'record should be destroyed' do
    expect do
      subject

      expect(page).to have_flash_message('Routing tag was successfully destroyed.', type: :notice)
    end.to change { Routing::RoutingTag.count }.by(-1)
  end

  context 'when Tag has CustomersAuth' do
    before do
      FactoryBot.create(:customers_auth, tag_action_value: [record.id])
    end

    include_examples :tag_can_not_be_destoryed, 'Routing tag could not be removed. Has related Customer Auth.'
  end

  context 'when Tag has Numberlist' do
    before do
      FactoryBot.create(:numberlist, tag_action_value: [record.id])
    end

    include_examples :tag_can_not_be_destoryed, 'Routing tag could not be removed. Has related Numberlist.'
  end

  context 'when Tag has NumberlistItem' do
    before do
      FactoryBot.create(:numberlist_item, tag_action_value: [record.id])
    end

    include_examples :tag_can_not_be_destoryed, 'Routing tag could not be removed. Has related Numberlist Item.'
  end

  context 'when Tag has RoutingTagDetectionRule' do
    before do
      FactoryBot.create(:routing_tag_detection_rule,
             tag_action_value: [record.id])
    end

    include_examples :tag_can_not_be_destoryed, 'Routing tag could not be removed. Has related Detection Rule.'
  end

  context 'when Tag has Dialpeer' do
    before do
      FactoryBot.create(:dialpeer, routing_tag_ids: [record.id])
    end

    include_examples :tag_can_not_be_destoryed, 'Routing tag could not be removed. Has related Dialpeer.'
  end

  context 'when Tag has Destination' do
    before do
      FactoryBot.create(:destination, routing_tag_ids: [record.id])
    end

    include_examples :tag_can_not_be_destoryed, 'Routing tag could not be removed. Has related Destination.'
  end

  context 'when Tag has few associations' do
    before do
      FactoryBot.create(:customers_auth, tag_action_value: [record.id])
      FactoryBot.create(:numberlist, tag_action_value: [record.id])
      FactoryBot.create(:numberlist_item, tag_action_value: [record.id])
      FactoryBot.create(:routing_tag_detection_rule, tag_action_value: [record.id])
      FactoryBot.create(:dialpeer, routing_tag_ids: [record.id])
      FactoryBot.create(:destination, routing_tag_ids: [record.id])
    end

    include_examples :tag_can_not_be_destoryed, 'Routing tag could not be removed. Has related Customer Auth,'\
                                                            ' Numberlist, Numberlist Item, Detection Rule, Dialpeer, Destination.'
  end
end
