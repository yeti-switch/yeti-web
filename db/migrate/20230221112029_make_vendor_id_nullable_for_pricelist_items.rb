class MakeVendorIdNullableForPricelistItems < ActiveRecord::Migration[6.1]
  def up
    change_column_null :'ratemanagement.pricelist_items', :vendor_id, true
  end

  def down
    change_column_null :'ratemanagement.pricelist_items', :vendor_id, false
  end
end
