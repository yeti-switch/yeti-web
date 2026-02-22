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
           routing_tag_ids: nil,
           legb_ruri: 'sip:+3809722334455@ims.example.com'
  end

  let!(:cdrs) do
    create_list :cdr, 2,
                :with_id,
                time_start: 1.hour.ago.utc,
                routing_tag_ids: [tag_ua.id, 321, tag_us.id]
  end

  let(:filter!) { nil }

  it 'shows CDRs with correct routing tags and masked legb_ruri' do
    subject
    expect(page).to have_table_row(count: 3)

    within_table_row(id: cdr_no_tags.id) do
      expect(page).to have_table_cell(column: 'Id', exact_text: cdr_no_tags.id)
      expect(page).to have_table_cell(column: 'Routing Tags', exact_text: '')
      expect(page).to have_table_cell(column: 'Legb Ruri', exact_text: 'sip:+3809722334***@ims.example.com')
    end

    within_table_row(id: cdrs.first.id) do
      expect(page).to have_table_cell(column: 'Id', exact_text: cdr_no_tags.id)
      expect(find(table_cell_selector('Routing Tags')).text.split).to match_array([tag_ua.name, '321', tag_us.name])
      within_table_cell('Routing Tags') do
        expect(page).to have_selector('.status_tag.ok', exact_text: tag_ua.name)
        expect(page).to have_selector('.status_tag.no', exact_text: '321')
        expect(page).to have_selector('.status_tag.ok', exact_text: tag_us.name)
      end
    end

    within_table_row(id: cdrs.second.id) do
      expect(page).to have_table_cell(column: 'Id', exact_text: cdr_no_tags.id)
      expect(find(table_cell_selector('Routing Tags')).text.split).to match_array([tag_ua.name, '321', tag_us.name])
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
        fill_in_tom_select 'WITH ROUTING TAG', with: routing_tag.name
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
      expect(find(table_cell_selector('Routing Tags')).text.split).to match_array([routing_tag.name.upcase, tag_ua.name.upcase])
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

  describe 'Visible columns feature' do
    context 'when click to "Reset" link' do
      subject { click_link :Reset }

      let!(:admin_user) { create :admin_user, visible_columns: { cdrs: %w[id] } }

      before { visit cdrs_path }

      it 'should click to "Reset" link', js: true do
        expect do
          subject
          expect(page).to have_no_link('Reset')
        end.to change { admin_user.reload.visible_columns['cdrs'] }.from(%w[id]).to('')
      end
    end

    context 'when select the several columns and submit form' do
      subject { click_button 'Show' }

      let!(:admin_user) { create :admin_user, visible_columns: { cdrs: %w[id] } }

      before do
        visit cdrs_path
        click_link 'Visible columns'
        select 'time_start', from: 'select_available_columns'
        select 'time_end', from: 'select_available_columns'
      end

      it 'should reload index page and then render only selected columns', js: true do
        expect { subject }.to change { admin_user.reload.visible_columns }.from({ 'cdrs' => %w[id] }).to({ 'cdrs' => %w[id time_start time_end] })
      end
    end
  end
end
