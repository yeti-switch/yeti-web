# frozen_string_literal: true

require 'spec_helper'

describe 'Export Disconnect Policies', type: :feature do
  include_context :login_as_admin

  before { create(:disconnect_policy) }

  let!(:item) do
    create(:disconnect_policy)
  end

  before do
    visit disconnect_policies_path(format: :csv)
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
