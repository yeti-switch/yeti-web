# frozen_string_literal: true

module JsonapiModel
  class OriginatedCps < Base
    include ActiveModel::Validations::Callbacks

    attr_accessor :account_id, :customer
    attr_reader :from_time, :to_time, :cps

    before_validation do
      self.from_time ||= 24.hours.ago
      self.to_time ||= Time.now
    end

    validates :customer, :account, presence: true

    validate do
      errors.add(:base, 'from_time must be greater than to_time') if from_time > to_time
    end

    def _save
      scope = Cdr::Cdr
              .where(customer_acc_id: account.id, routing_attempt: 1)
              .where('time_start BETWEEN ? AND ?', from_time, to_time)
              .group("date_trunc('minute',time_start)")
              .order("date_trunc('minute',time_start)")

      values = scope.pluck("date_trunc('minute',time_start)", 'round((count(*)::float/60)::decimal,3)')

      @cps = values.map do |(time_start, cps)|
        { x: cps, y: time_start.to_s(:db) }
      end
    end

    def account
      return @account if defined?(@account)

      @account = account_id && customer ? customer.accounts.find_by(uuid: account_id) : nil
    end

    def from_time=(val)
      @from_time = ActiveModel::Type::DateTime.new.cast(val)
    end

    def to_time=(val)
      @to_time = ActiveModel::Type::DateTime.new.cast(val)
    end
  end
end
