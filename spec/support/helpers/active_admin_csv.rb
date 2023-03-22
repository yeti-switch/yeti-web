# frozen_string_literal: true

module Helpers
  module ActiveAdminCsv
    def page_csv
      byte_order_mark = ActiveAdmin.application.csv_options[:byte_order_mark]
      body = page.body
      body = body.sub(byte_order_mark, '') unless byte_order_mark.nil?
      CSV.parse(body)
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::ActiveAdminCsv
end
