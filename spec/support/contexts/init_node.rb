# frozen_string_literal: true

shared_context :init_node do |args|
  args ||= {}

  before do
    fields = {
        name: 'Local node',
        id: 100500,
        pop_id: @pop.id,
        rpc_endpoint: '127.1.2.3:7899'
    }.merge(args)

    @node = FactoryBot.create(:node, fields)
  end
end
