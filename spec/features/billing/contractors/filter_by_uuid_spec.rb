# frozen_string_literal: true

RSpec.describe 'Filter Contractors by uuid', type: :feature do
  include_context :login_as_admin

  let!(:wanted) { create(:customer) }
  let!(:other) { create(:customer) }

  it 'shows the uuid on the index' do
    visit contractors_path

    expect(page).to have_content(wanted.uuid)
    expect(page).to have_content(other.uuid)
  end

  it 'narrows the index to the contractor behind a uuid' do
    visit contractors_path(q: { uuid_eq: wanted.uuid })

    expect(page).to have_css('.resource_id_link', text: wanted.id)
    expect(page).to have_no_css('.resource_id_link', text: other.id)
  end

  it 'returns nothing for a uuid nobody holds' do
    visit contractors_path(q: { uuid_eq: SecureRandom.uuid })

    expect(page).to have_no_css('.resource_id_link', text: wanted.id)
    expect(page).to have_no_css('.resource_id_link', text: other.id)
  end

  it 'keeps the other filters alongside the uuid filter' do
    visit contractors_path

    expect(page).to have_field('q[uuid_eq]')
    expect(page).to have_field('q[name_cont]')
  end

  it 'shows the uuid directly after the id on the show page' do
    visit contractor_path(wanted)

    labels = page.all('.attributes_table th').map(&:text)
    expect(labels.first(2)).to eq(%w[Id Uuid])
    expect(page).to have_content(wanted.uuid)
  end
end
