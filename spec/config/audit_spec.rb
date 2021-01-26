# frozen_string_literal: true

RSpec.describe 'config/audit.yml' do
  subject do
    Rails.configuration.audit
  end

  let(:audit_config) do
    {
      'Account' => true,
      'Routing/NumberlistItem' => false,
      'Node' => true
    }
  end

  let!(:vendor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, contractor: vendor) }
  let!(:numberlist_item) { FactoryBot.create(:numberlist_item) }
  let!(:node) { FactoryBot.create(:node) }

  it 'should have correct config structure' do
    expect(subject.keys).to(
      match_array(audit_config.keys),
      "expected root keys to be #{audit_config.keys}, but found #{subject.keys}"
    )
  end

  it 'should update versions on creation' do
    expect(vendor.versions.count).to eq(1)
    expect(account.versions.count).to eq(1)
    expect(numberlist_item.versions.count).to eq(1)
    expect(node.versions.count).to eq(1)
  end

  it 'should update versions after object modification only for class declared with `true` value or for non declared in config' do
    expect { vendor.update(name: 'Test Name') }.to change { vendor.versions.count }.by(1)
    expect { account.update(name: 'Test Name') }.to change { account.versions.count }.by(1)
    expect { numberlist_item.update(dst_rewrite_rule: 'any') }.to change { numberlist_item.versions.count }.by(0)
    expect { node.update(name: 'Test Name') }.to change { node.versions.count }.by(1)
  end

  it 'should update versions on deletion' do
    expect(vendor.versions.count).to eq(1)
    expect { account.destroy }.to change { account.versions.count }.by(1)
    expect { numberlist_item.destroy }.to change { numberlist_item.versions.count }.by(1)
    expect { node.destroy }.to change { node.versions.count }.by(1)
  end
end
