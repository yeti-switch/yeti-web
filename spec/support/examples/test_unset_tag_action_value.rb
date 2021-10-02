# frozen_string_literal: true

RSpec.shared_examples :test_unset_tag_action_value do |factory: nil, controller_name:|
  let(:tag) do
    create(:routing_tag, :ua)
  end

  let(:record) do
    create(factory, tag_action_value: [tag.id])
  end

  subject do
    visit "/#{controller_name}/#{record.id}/edit"

    within 'li', text: 'Tag action value' do
      page.unselect tag.name
    end
    find('input[type=submit]').click
  end

  it 'saves empyt array' do
    subject
    find('body.show') # wait page load
    expect(record.reload.tag_action_value).to be_empty
  end
end
