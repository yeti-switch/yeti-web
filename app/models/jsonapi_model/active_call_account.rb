# frozen_string_literal: true

module JsonapiModel
  class ActiveCallAccount < Base
    include ActiveModel::Validations::Callbacks

    attr_accessor :account_id, :customer
    attr_reader :from_time, :to_time, :originated_calls, :terminated_calls

    before_validation do
      self.from_time ||= 24.hours.ago
      self.to_time ||= Time.now
    end

    validates :customer, :account, presence: true

    validate do
      errors.add(:base, 'from_time must be greater than to_time') if from_time > to_time
    end

    def _save
      scope = Stats::ActiveCallAccount
              .where(account_id: account.id)
              .where('created_at BETWEEN ? AND ?', from_time, to_time)

      values = scope.pluck(:created_at, :terminated_count, :originated_count)

      @originated_calls = []
      @terminated_calls = []

      values.each do |(created_at, terminated_count, originated_count)|
        created_at_formatted = created_at.to_s(:db)
        originated_calls.push(x: originated_count, y: created_at_formatted)
        terminated_calls.push(x: terminated_count, y: created_at_formatted)
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
