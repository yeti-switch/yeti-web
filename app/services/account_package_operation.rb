  class AccountPackageOperation < BaseService
    attr_reader :account

    def initialize(account_id:)
      @account = Account.find(account_id)
    end

    def save_current(package_id)
      package = Billing::Package.find(package_id)

      Account.transaction do
        account.update!(package_id: package_id)

        unless (account.balance - package.price) > account.min_balance
          raise(StandardError, 'Not enough money for package configuration')
        end

        package.configurations.each do |config|
          account.prepaid_packages.create(prefix: config.prefix)
        end

        account.payments.create(amount: -package.price)
      end
    end

    # def save_next(id)
    #
    # end
  end
