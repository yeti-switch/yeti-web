# frozen_string_literal: true

class Routing::CustomerAuthDstNumberField < Yeti::ActiveRecord
  self.table_name = 'class4.customers_auth_dst_number_fields'

  def display_name
    name.to_s
  end
end
