# frozen_string_literal: true

RSpec.describe 'CDR show', type: :feature do
  subject do
    visit cdr_path(id: cdr.id)
  end

  include_context :login_as_admin
  include_context :init_routing_tag_collection

  let!(:cdr) do
    create(:cdr, :with_id, cdr_attrs)
  end
  let(:cdr_attrs) do
    {
      time_start: 1.hour.ago.utc,
      routing_tag_ids: [@tag_ua.id, @tag_us.id]
    }
  end

  it 'shows CDR with correct attributes' do
    subject
    expect(page).to have_table_row(count: 1)
    expect(page).to have_attribute_row('ID', exact_text: cdr.id)
    expect(page).to have_attribute_row('Routing Tags', exact_text: "#{@tag_ua.name} #{@tag_us.name}")
    within_attribute_row('Routing Tags') do
      expect(page).to have_selector('.status_tag.ok', text: @tag_ua.name)
      expect(page).to have_selector('.status_tag.ok', text: @tag_us.name)
    end
  end

  it 'does not have link to create new cdr' do
    subject
    expect(page).to have_selector('tr.row-routing_tags')
    expect(page).to_not have_selector('.title_bar .action_items .action_item a[href="/cdrs/new"]')
  end

  context 'when CDR has no routing tags' do
    let(:cdr_attrs) do
      super().merge routing_tag_ids: []
    end

    it 'shows CDR with correct attributes' do
      subject
      expect(page).to have_table_row(count: 1)
      expect(page).to have_attribute_row('ID', exact_text: cdr.id)
      expect(page).to have_attribute_row('Routing Tags', exact_text: 'Empty')
      within_attribute_row('Routing Tags') do
        expect(page).to have_selector('.empty', exact_text: 'Empty')
      end
    end
  end

  context 'when CDR has not recognized routing tag' do
    let(:cdr_attrs) do
      super().merge routing_tag_ids: [@tag_ua.id, 9454, @tag_us.id]
    end

    it 'shows CDR with correct attributes' do
      subject
      expect(page).to have_table_row(count: 1)
      expect(page).to have_attribute_row('ID', exact_text: cdr.id)
      expect(page).to have_attribute_row('Routing Tags', exact_text: "#{@tag_ua.name} 9454 #{@tag_us.name}")
      within_attribute_row('Routing Tags') do
        expect(page).to have_selector('.status_tag.ok', exact_text: @tag_ua.name)
        expect(page).to have_selector('.status_tag.no', exact_text: '9454')
        expect(page).to have_selector('.status_tag.ok', exact_text: @tag_us.name)
      end
    end
  end
end
