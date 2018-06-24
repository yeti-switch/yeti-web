RSpec.describe 'CDR show', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before { Cdr::Cdr.destroy_all }
  after { Cdr::Cdr.destroy_all }

  let!(:cdrs) do
    create_list :cdr, 12,
                :with_id,
                time_start: 1.hour.ago.utc,
                routing_tag_ids: [@tag_ua.id, @tag_us.id]
  end

  before do
    visit cdr_path(id: cdrs.last.id)
  end

  it_behaves_like :test_page_has_routing_tag_names do
    subject do
      page.find('tr.row-routing_tags td')
    end
  end
end
