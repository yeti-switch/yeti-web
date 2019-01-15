# frozen_string_literal: true

RSpec.shared_examples :test_page_has_routing_tag_names do
  # subjec { target row or column "td.col-routing_tags" }

  it 'column/row has routing_tag_ids display Names insted of IDs' do
    expect(subject).to have_css('.status_tag', text: 'UA_CLI')
    expect(subject).to have_css('.status_tag', text: 'US_CLI')
  end
end
