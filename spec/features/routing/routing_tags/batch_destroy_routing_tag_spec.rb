# frozen_string_literal: true

RSpec.describe 'Batch Destroy Routing Routing Tag', type: :feature, js: true do
  include_context :login_as_admin

  let!(:tags) { FactoryBot.create_list(:routing_tag, 3) }

  shared_examples :tag_can_not_be_destoryed do |message|
    it 'should not be destroyed' do
      expect do
        subject

        expect(page).to have_flash_message(message, type: :alert)
      end.not_to change { Routing::RoutingTag.count }
    end
  end

  subject do
    visit routing_routing_tags_path
    table_select_all
    # ActiveAdmin 4 confirms batch actions through rails-ujs `data-confirm`, a
    # native browser dialog raised DURING the click — so it must be accepted
    # around the click, not after it as AA3's in-page modal was.
    accept_confirm { click_batch_action('Delete Selected') }
  end

  it 'record should be destroyed' do
    expect do
      subject

      expect(page).to have_flash_message("Successfully deleted #{tags.size}/#{tags.size} routing routing tags", type: :notice)
    end.to change { Routing::RoutingTag.count }.by(-tags.size)
  end

  context 'when tag has related associations' do
    before do
      FactoryBot.create(:customers_auth, tag_action_value: [tags.first.id])
    end

    it 'record should be destroyed' do
      expect do
        subject

        expect(page).to have_flash_message("Successfully deleted #{tags.size - 1}/#{tags.size} routing routing tags", type: :notice)
      end.to change { Routing::RoutingTag.count }.by(-tags.size + 1)
    end
  end
end
