# frozen_string_literal: true

RSpec.shared_examples :test_unset_routing_tag_ids do |factory: nil, controller_name:|
  let(:tag) do
    create(:routing_tag, :ua)
  end

  let(:record) do
    create(factory, routing_tag_ids: [tag.id, nil])
  end

  before do
    visit "/#{controller_name}/#{record.id}/edit"

    within 'li', text: 'Routing tag ids' do
      page.unselect tag.name
      page.unselect Routing::RoutingTag::ANY_TAG
    end
    find('input[type=submit]').click
  end

  it 'saves empyt array' do
    # AA4 puts no action/resource classes on <body>; the show page is identified
    # by the attributes table it renders (the edit page does not have one).
    # Existence check, not `find`: several resources render more than one
    # attributes table on their show page, and `find` demands exactly one match.
    expect(page).to have_selector('.attributes-table') # wait page load
    expect(record.reload.routing_tag_ids).to be_empty
  end
end
