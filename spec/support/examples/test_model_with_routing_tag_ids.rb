RSpec.shared_examples :test_model_with_routing_tag_ids do

  include_context :init_routing_tag_collection

  let(:random_tags) do
    Routing::RoutingTag.pluck(:id).take(2)
  end

  it 'allows routing_tag_ids to be empty' do
    expect(subject).to allow_value([]).for(:routing_tag_ids)
  end

  it 'allows routing_tag_ids to contain NULL element' do
    values = random_tags.dup.push(nil)
    expect(subject).to allow_value(values).for(:routing_tag_ids)
  end

  it 'does not allow routing_tag_ids to contain duplicate values' do
    values = random_tags.dup.push(random_tags.first) # => [1, 2, 1]
    expect(subject).not_to allow_value(values).for(:routing_tag_ids)
  end

  it 'does not allow routing_tag_ids to contain duplicate NULL-s' do
    values = random_tags + [nil, nil] # => [1, 2, nil, nil]
    expect(subject).not_to allow_value(values).for(:routing_tag_ids)
  end

end
