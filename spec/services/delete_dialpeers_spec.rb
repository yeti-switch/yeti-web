# frozen_string_literal: true

RSpec.describe DeleteDialpeers do
  subject { described_class.call(dialpeer_ids: dialpeer_ids) }

  let!(:dialpeers) do
    FactoryBot.create_list(:dialpeer, 3)
  end

  let(:dialpeer_ids) { dialpeers.map(&:id) }

  before do
    # another dialpeers
    FactoryBot.create_list(:dialpeer, 3)
  end

  it 'should remove dialpeers' do
    expect { subject }.to change(Dialpeer, :count).by(-dialpeers.size)

    dialpeers.each do |dialpeer|
      expect(Dialpeer).not_to be_exists(dialpeer.id)
    end
  end
end
