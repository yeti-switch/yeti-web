# frozen_string_literal: true

module JsonapiModel
  class ActiveCallAccount < Base
    attribute :account_id, :string
    attribute :customer
    attribute :from_time, :datetime, default: proc { 24.hours.ago }
    attribute :to_time, :datetime, default: proc { Time.current }

    normalize_attribute :from_time, with: ->(from_time) { from_time.in_time_zone }
    normalize_attribute :to_time, with: :in_time_zone

    attr_reader :originated_calls, :terminated_calls

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
      scope = Stats::ActiveCallAccount
              .where(account_id: account.id)
              .where('created_at BETWEEN ? AND ?', from_time.in_time_zone, to_time.in_time_zone)
              .order('created_at')

      values = scope.pluck(:created_at, :terminated_count, :originated_count)

      @originated_calls = []
      @terminated_calls = []

      values.each do |(created_at, terminated_count, originated_count)|
        created_at_formatted = created_at.in_time_zone.iso8601(3)
        originated_calls.push(y: originated_count, x: created_at_formatted)
        terminated_calls.push(y: terminated_count, x: created_at_formatted)
      end
    end
  end
end
