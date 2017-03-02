shared_examples 'after_import_hook when real items do not match' do

  # Before running this test, all "belongs_to"-fields should be set to nil
  it 'resolve relations' do
    # Select names of belongs_to fields, and pack it to array like this: ['pop_id', 'node_id']
    associations = described_class.import_class.reflect_on_all_associations(:belongs_to).map(&:foreign_key).map(&:to_s)
    # Compare only associated fields by using slice on hash
    # example:
    # before    {"pop_id"=>nil, "node_id"=>nil}
    # and after {"pop_id"=>3, "node_id"=>10}
    if associations.any?
      expect{ subject }.to change{ preview_item.reload.as_json.slice(*associations) }
    end
  end

  # before running this test, preview_item.o_id should be set to not nil
  it 'nullify o_id' do
    expect{ subject }.to change{ preview_item.reload.o_id }.to(nil)
  end
end

shared_examples 'after_import_hook when real items match' do

  it 'resolves o_id - match real item id' do
    expect{ subject }.to change{ preview_item.reload.o_id }.to(real_item.id)
  end
end
