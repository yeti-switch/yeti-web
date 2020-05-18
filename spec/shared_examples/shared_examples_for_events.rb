# frozen_string_literal: true

RSpec.shared_examples 'Event originator for all Nodes' do
  shared_examples 'test events sender' do
    it 'sends proper Events' do
      expect { action }.to change { Event.where(command: request_command).count }.by(Node.count)
    end
  end

  context '#create' do
    include_examples 'test events sender' do
      let(:action) { FactoryBot.create(object_name, object_fields) }
    end
  end

  context 'when record exists' do
    let!(:obj_originator) do
      FactoryBot.create(object_name, object_fields)
    end

    context '#update' do
      include_examples 'test events sender' do
        let(:action) { obj_originator.update_attribute(:name, 'New name') }
      end
    end

    context '#delete' do
      include_examples 'test events sender' do
        let(:action) { obj_originator.destroy }
      end
    end
  end
end
