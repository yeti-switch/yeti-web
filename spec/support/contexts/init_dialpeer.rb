# frozen_string_literal: true

shared_context :init_dialpeer do |args|
  args ||= {}

  before do
    fields = {
      enabled: true,
      prefix: '34918051239',
      src_rewrite_rule: '',
      dst_rewrite_rule: '',
      acd_limit: 0.0,
      asr_limit: 0.0,
      routing_group_id: @routing_group.id,
      next_rate: 0.0092,
      connect_fee: 0.0,
      vendor_id: @contractor.id,
      account_id: @account.id,
      gateway_id: @gateway.id,
      src_rewrite_result: '',
      dst_rewrite_result: '',
      locked: false,
      priority: 105,
      capacity: 1,
      lcr_rate_multiplier: 1.0,
      initial_rate: 0.0092,
      initial_interval: 1,
      next_interval: 1
    }.merge(args)

    @dialpeer = FactoryGirl.create(:dialpeer, fields)
  end
end
