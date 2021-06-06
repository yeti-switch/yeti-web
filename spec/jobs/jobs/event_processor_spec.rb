# frozen_string_literal: true

RSpec.describe Jobs::EventProcessor, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  context 'without events' do
    it 'does not do anything' do
      expect { subject }.to_not change { Event.count }.from(0)
    end
  end

  context 'when event with only method' do
    let!(:node) { create(:node) }
    before do
      create(:event, node: node, command: 'some.test.method.name')
      stub_jrpc_request(node.rpc_endpoint, 'yeti.some.test.method.name', [])
        .and_return(nil)
    end

    it 'expects to delete success events' do
      expect { subject }.to change { Event.count }.from(1).to(0)
    end
  end

  context 'when event with method and arg' do
    let!(:node) { create(:node) }
    before do
      create(:event, node: node, command: 'some.test.method.name foo')
      stub_jrpc_request(node.rpc_endpoint, 'yeti.some.test.method.name', ['foo'])
        .and_return(nil)
    end

    it 'expects to delete success events' do
      expect { subject }.to change { Event.count }.from(1).to(0)
    end
  end

  context 'when event with method and 2 args' do
    let!(:node) { create(:node) }
    before do
      create(:event, node: node, command: 'some.test.method.name foo bar')
      stub_jrpc_request(node.rpc_endpoint, 'yeti.some.test.method.name', %w[foo bar])
        .and_return(nil)
    end

    it 'expects to delete success events' do
      expect { subject }.to change { Event.count }.from(1).to(0)
    end
  end

  context 'with reload_translations events' do
    let!(:nodes) { create_list(:node, nodes_qty) }
    let(:nodes_qty) { 3 }
    before do
      Event.reload_translations
    end

    context 'with successful events' do
      before do
        nodes.each do |node|
          stub_jrpc_request(node.rpc_endpoint, 'yeti.request.router.translations.reload', [])
            .and_return(nil)
        end
      end

      it 'expects to delete success events' do
        expect { subject }.to change { Event.count }.from(nodes_qty).to(0)
      end
    end

    context 'when one event failed' do
      let(:nodes_qty) { 1 }
      before do
        stub_jrpc_request(nodes.first.rpc_endpoint, 'yeti.request.router.translations.reload', [])
          .and_raise(StandardError, 'some error')
      end

      it 'expects to not delete events' do
        expect { subject }.to_not change { Event.count }.from(nodes_qty)
      end

      it 'test' do
        event = Event.last!
        subject

        expect(event.reload).to have_attributes(
                                  retries: 1,
                                  last_error: be_present
                                )
      end

      include_examples :captures_error
    end
  end

  context 'with reload_sip_options_probers events' do
    let!(:node) { create(:node) }
    before do
      Event.reload_sip_options_probers(node_id: node.id)
    end

    before do
      stub_jrpc_request(node.rpc_endpoint, 'yeti.request.options_prober.reload', [])
        .and_return(nil)
    end

    it 'expects to delete success events' do
      expect { subject }.to change { Event.count }.from(1).to(0)
    end
  end
end
