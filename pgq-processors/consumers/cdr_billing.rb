class  CdrBilling < Pgq::ConsumerGroup
  @consumer_name = 'cdr_billing'


  def perform_events(events)
    group = []
    events.each do |event|
      group << event.data
    end
    perform_group(group)
  end

    # {'type' => [events]}
  def perform_group(group)
    ::RoutingBase.execute_sp('SELECT * FROM billing.bill_cdr_batch(?, ?)', @batch_id, self.coder.dump(group))
  end

end
