# frozen_string_literal: true

RSpec.describe 'Index Codec Groups', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    codec_groups = create_list(:codec_group, 2)
    visit codec_groups_path
    codec_groups.each do |codec_group|
      expect(page).to have_css('.resource_id_link', text: codec_group.id)
    end
  end
end
