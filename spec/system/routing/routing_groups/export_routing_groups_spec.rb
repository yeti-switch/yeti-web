# frozen_string_literal: true

require 'spec_helper'

describe 'Export Routing Groups' do
  include_context :login_as_admin

  before { create(:routing_group) }

  let!(:item) do
    create(:routing_group)
  end

  before do
    visit routing_groups_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Name', item.name]
      ]
    )
  end
end
