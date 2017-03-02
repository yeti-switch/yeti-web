class Stats::ActiveCallAccount
  attr_accessor :account_id

  def initialize(account_id)
     @account_id = account_id
  end

  def to_chart
    lines = []
    lines << Stats::ActiveCallVendorAccount.to_chart(account_id, { area: false, key: 'Vendor' })
    lines << Stats::ActiveCallCustomerAccount.to_chart(account_id,  { area: false, key: 'Account' })
    lines.flatten
  end

end