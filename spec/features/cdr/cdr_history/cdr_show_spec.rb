# frozen_string_literal: true

RSpec.describe 'CDR show', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  let!(:cdrs) do
    create_list :cdr, 12,
                :with_id,
                time_start: 1.hour.ago.utc,
                routing_tag_ids: [@tag_ua.id, @tag_us.id]
  end

  before do
    visit cdr_path(id: cdrs.last.id)
  end

  it 'does not have link to create new cdr' do
    subject
    expect(page).to have_selector('tr.row-routing_tags')
    expect(page).to_not have_selector('.title_bar .action_items .action_item a[href="/cdrs/new"]')
  end

  it_behaves_like :test_page_has_routing_tag_names do
    subject do
      page.find('tr.row-routing_tags td')
    end
  end
end
