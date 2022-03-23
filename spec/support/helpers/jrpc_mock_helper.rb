# frozen_string_literal: true

module JRPCMockHelper
  # DSL allows stub JRPC in test environment.
  # Example:
  #
  #   let!(:node) { FactoryBot.create(:node) }
  #   before do
  #     stub_jrpc_request(node.rpc_endpoint, 'yeti.show.registrations', [123]).and_return({ bar: 'baz' })
  #   end
  #
  #   it 'calls correctly' do
  #     expect(node.api.registration(123)).to match({ bar: 'baz' })
  #   end

  class StubHelper
    def initialize(stub:, ctx:, meth:, params: [])
      @stub = stub
      @ctx = ctx
      @meth = meth
      @params = params
    end

    def and_return(*args)
      create_stub.and_return(*args)
    end

    def and_raise(*args)
      create_stub.and_raise(*args)
    end

    private

    def create_stub
      @ctx.expect(@stub).to @ctx.receive(:perform_request).with(@meth, params: @params)
    end
  end

  def stub_jrpc_request(uri_or_stub, meth, params)
    jrpc_tcp_stub = uri_or_stub.is_a?(String) ?
      stub_jrpc_connect(uri_or_stub) : uri_or_stub

    StubHelper.new(stub: jrpc_tcp_stub, ctx: self, meth: meth, params: params)
  end

  def stub_jrpc_connect(uri)
    options = NodeApi.default_options
    jrpc_tcp_stub = instance_double(::JRPC::TcpClient, closed?: false, close: nil)
    expect(::JRPC::TcpClient).to receive(:new).with(uri, options).and_return(jrpc_tcp_stub)
    jrpc_tcp_stub
  end

  def stub_jrpc_connect_error(uri, error_class: JRPC::ConnectionError, error_msg: nil)
    error_msg ||= "can't connect to #{uri}"
    options = NodeApi.default_options
    expect(::JRPC::TcpClient).to receive(:new).with(uri, options).and_raise(error_class, error_msg)
  end
end
