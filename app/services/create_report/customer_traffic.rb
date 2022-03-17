# frozen_string_literal: true

module CreateReport
  class CustomerTraffic < Base
    parameter :customer
    parameter :date_start
    parameter :date_end

    private

    def create_report!
      Report::CustomerTraffic.create!(
        customer: customer,
        date_start: date_start,
        date_end: date_end,
        send_to: send_to.presence
      )
    end

    def validate!
      super
      raise Error, 'customer must be present' if customer.blank?
    end
  end
end
