module CsvReport
  extend ActiveSupport::Concern

  included do
    attr_accessor :send_to

    validate do
      if self.send_to.present? and self.send_to.any?
        self.errors.add(:send_to, :invalid) if contacts.count != self.send_to.count
      end
    end

    def send_to=(send_to_ids)
      @send_to = send_to_ids.reject { |i| i.blank? }
    end

    def contacts
      unless instance_variable_defined?(:@contacts)
        @contacts ||= Billing::Contact.where(id: self.send_to)
      end
      @contacts
    end

  end

end