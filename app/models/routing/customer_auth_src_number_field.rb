# frozen_string_literal: true

class Routing::CustomerAuthSrcNumberField < Yeti::ActiveRecord
  self.table_name = 'class4.customers_auth_src_number_fields'

  def display_name
    name.to_s
  end
end
