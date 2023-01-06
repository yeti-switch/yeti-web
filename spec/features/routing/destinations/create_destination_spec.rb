# frozen_string_literal: true

RSpec.describe 'Create new Destinations', type: :feature do
  include_context :login_as_admin

  context 'success' do
    let!(:tag) { create(:routing_tag, :ua) }
    let!(:rate_group) { create(:rate_group) }
    let!(:rateplan) { create(:rateplan) }

    before { visit new_destination_path }

    include_context :fill_form, 'new_routing_destination'

    let(:attributes) do
      {
        batch_prefix: '123',
        enabled: true,
        reject_calls: true,
        rate_group_id: rate_group.name,
        reverse_billing: true,
        initial_rate: 60,
        next_rate: 30,
        profit_control_mode_id: rateplan.profit_control_mode_name,
        routing_tag_ids: [tag.name, Routing::RoutingTag::ANY_TAG]
      }
    end

    it 'creates new Destination and show it' do
      click_on_submit
      expect(page).to have_css('body.show.destinations')

      expect(Routing::Destination.last).to have_attributes(
        prefix: attributes[:batch_prefix],
        enabled: attributes[:enabled],
        reject_calls: attributes[:reject_calls],
        rate_group_id: rate_group.id,
        reverse_billing: true,
        initial_rate: attributes[:initial_rate],
        next_rate: attributes[:next_rate],
        profit_control_mode_id: rateplan.profit_control_mode_id,
        routing_tag_ids: [tag.id, nil]
      )
    end
  end
end
