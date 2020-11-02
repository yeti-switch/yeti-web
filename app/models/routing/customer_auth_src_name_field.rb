# frozen_string_literal: true

class Routing::CustomerAuthSrcNameField < Yeti::ActiveRecord
  self.table_name = 'class4.customers_auth_src_name_fields'

  def display_name
    name.to_s
  end
end
