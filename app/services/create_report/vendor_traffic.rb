# frozen_string_literal: true

module CreateReport
  class VendorTraffic < Base
    parameter :vendor
    parameter :date_start
    parameter :date_end

    private

    def create_report!
      Report::VendorTraffic.create!(
        vendor: vendor,
        date_start: date_start,
        date_end: date_end,
        send_to: send_to.presence
      )
    end

    def validate!
      super
      raise Error, 'vendor must be present' if vendor.blank?
    end
  end
end
