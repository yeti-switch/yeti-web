require 'spec_helper'

describe 'CDRs index', type: :feature do
  include_context :login_as_admin
  include_context :init_routing_tag_collection

  before { Cdr::Cdr.destroy_all }
  after { Cdr::Cdr.destroy_all }

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
                routing_tag_ids: [@tag_ua.id, 321, @tag_us.id]
  end

  before do
    visit cdrs_path
  end

  it_behaves_like :test_page_has_routing_tag_names do
    subject do
      page.find("#cdr_cdr_#{cdrs.last.id}").find('td.col-routing_tags')
    end

    it 'display not existing Tag ID in in grey-color' do
      expect(subject).to have_css('.status_tag.no:not(.yes)', text: '321')
    end

    it 'display EMPTY when CDR has no tags' do
      tr = page.find("#cdr_cdr_#{cdr_no_tags.id}").find('td.col-routing_tags')
      expect(tr.text).to be_empty
    end
  end

end
