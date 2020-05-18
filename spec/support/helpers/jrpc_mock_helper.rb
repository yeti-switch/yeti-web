# frozen_string_literal: true

module JRPCMockHelper
  # DSL allows stub JRPC in test environment.
  # Example:
  #
  #   let!(:node) { FactoryBot.create(:node) }
  #   before do
  #     stub_jrpc_request(:registrations, node.rpc_endpoint).with(123).and_return({ bar: 'baz' })
  #   end
  #
  #   it 'calls correctly' do
  #     expect(node.api.registration(123)).to match({ bar: 'baz' })
  #   end

  class StubHelper
    def initialize(stub:, ctx:, meth:)
      @stub = stub
      @ctx = ctx
      @meth = meth
    end

    def with(*params)
      stub_with_params(params)
    end

    def and_return(*args)
      stub_with_params([]).and_return(*args)
    end

    private

    def stub_with_params(params)
      @ctx.expect(@stub).to @ctx.receive(:perform_request).with(@meth, params: params).once
    end
  end

  def stub_jrpc_request(meth, uri, options = nil)
    options ||= hash_including(namespace: 'yeti.')
    jrpc_tcp_stub = instance_double(::JRPC::TcpClient, closed?: false, close: nil)
    expect(::JRPC::TcpClient).to receive(:new).with(uri, options).and_return(jrpc_tcp_stub)
    StubHelper.new(stub: jrpc_tcp_stub, ctx: self, meth: meth)
  end
end
