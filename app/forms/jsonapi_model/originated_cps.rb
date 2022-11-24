# frozen_string_literal: true

module JsonapiModel
  class OriginatedCps < Base
    include ActiveModel::Validations::Callbacks

    TIME_START_SQL = Arel.sql("date_trunc('minute',time_start)").freeze
    CPS_SQL = Arel.sql('round((count(*)::float/60)::decimal,3)').freeze

    attribute :account_id, :string
    attribute :customer
    attribute :from_time, :datetime, default: proc { 24.hours.ago }
    attribute :to_time, :datetime, default: proc { Time.current }

    attr_reader :cps

    validates :customer, :account, presence: true

    validate do
      errors.add(:base, 'from_time must be greater than to_time') if from_time > to_time
    end

    def account
      return @account if defined?(@account)

      @account = account_id && customer ? customer.accounts.find_by(uuid: account_id) : nil
    end

    private

    def _save
      scope = Cdr::Cdr
              .where(customer_acc_id: account.id, is_last_cdr: true)
              .where('time_start BETWEEN ? AND ?', from_time.in_time_zone, to_time.in_time_zone)
              .group(TIME_START_SQL)
              .order(TIME_START_SQL)

      values = scope.pluck(TIME_START_SQL, CPS_SQL)

      @cps = values.map do |(time_start, cps)|
        { y: cps, x: time_start.in_time_zone.iso8601(3) }
      end
    end
  end
end
