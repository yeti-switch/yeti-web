# frozen_string_literal: true

require 'spec_helper'

describe 'Show Contractors', type: :feature do
  subject do
    visit contractor_path(record.id)
  end

  include_context :login_as_admin
  let!(:record) { create(:vendor) }

  it 'has link to create new contractor' do
    subject
    expect(page).to have_selector(
      ".title_bar .action_items .action_item a[href=\"#{new_contractor_path}\"]",
      text: 'New Contractor',
      count: 1
    )
  end
end
