# frozen_string_literal: true

RSpec.describe 'CDRs index', type: :feature do
  subject do
    visit cdrs_path
    filter!
  end

  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before do
    create(:lnp_database, :thinq)
  end

  let!(:routing_tag) { create(:routing_tag) }
  let!(:cdr_no_tags) do
    create :cdr,
           :with_id,
           time_start: 1.hour.ago.utc,
           routing_tag_ids: nil
  end

  let!(:cdrs) do
    create_list :cdr, 2,
                :with_id,
                time_start: 1.hour.ago.utc,
                routing_tag_ids: [tag_ua.id, 321, tag_us.id]
  end

  let(:filter!) { nil }

  it 'shows CDRs with correct routing tags' do
    subject
    expect(page).to have_table_row(count: 3)

    within_table_row(id: cdr_no_tags.id) do
      expect(page).to have_table_cell(column: 'Id', exact_text: cdr_no_tags.id)
      expect(page).to have_table_cell(column: 'Routing Tags', exact_text: '')
    end

    within_table_row(id: cdrs.first.id) do
      expect(page).to have_table_cell(column: 'Id', exact_text: cdr_no_tags.id)
      expect(page).to have_table_cell(column: 'Routing Tags', exact_text: "#{tag_ua.name} 321 #{tag_us.name}")
      within_table_cell('Routing Tags') do
        expect(page).to have_selector('.status_tag.ok', exact_text: tag_ua.name)
        expect(page).to have_selector('.status_tag.no', exact_text: '321')
        expect(page).to have_selector('.status_tag.ok', exact_text: tag_us.name)
      end
    end

    within_table_row(id: cdrs.second.id) do
      expect(page).to have_table_cell(column: 'Id', exact_text: cdr_no_tags.id)
      expect(page).to have_table_cell(column: 'Routing Tags', exact_text: "#{tag_ua.name} 321 #{tag_us.name}")
      within_table_cell('Routing Tags') do
        expect(page).to have_selector('.status_tag.ok', exact_text: tag_ua.name)
        expect(page).to have_selector('.status_tag.no', exact_text: '321')
        expect(page).to have_selector('.status_tag.ok', exact_text: tag_us.name)
      end
    end
  end

  context 'with filter by routing tags', js: true do
    let(:filter!) do
      within_filters do
        fill_in_chosen 'With routing tag', with: routing_tag.name
        click_button('Filter')
      end
    end

    let!(:cdr_with_one_tag) do
      create(:cdr, routing_tag_ids: [routing_tag.id, tag_ua.id])
    end

    it 'shows one CDR with correct routing tags' do
      subject
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell(column: 'ID', exact_text: cdr_with_one_tag.id)
      expect(page).to have_table_cell(column: 'Routing Tags', exact_text: "#{routing_tag.name.upcase} #{tag_ua.name.upcase}")
    end
  end

  context 'with filter by customer auth external type', js: true do
    let(:filter!) do
      within_filters do
        fill_in 'CUSTOMER AUTH EXTERNAL TYPE', with: 'em'
        click_button('Filter')
      end
    end

    let!(:cdr) do
      create(:cdr, customer_auth_external_type: 'em')
    end

    it 'shows one CDR with correct routing tags' do
      subject
      expect(page).to have_table_row(count: 1)
      expect(page).to have_table_cell(column: 'ID', exact_text: cdr.id)
    end
  end
end
