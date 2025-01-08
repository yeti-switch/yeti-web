# frozen_string_literal: true

RSpec.describe Billing::Service::Renew do
  shared_examples :renews_service do
    it 'calls provisioning object callbacks' do
      stub = instance_double(Billing::Provisioning::Base)
      expect(service).to receive(:build_provisioning_object).and_return(stub)
      stub
      expect(stub).to receive(:before_renew).with(no_args).once.ordered
      expect(stub).to receive(:after_success_renew).with(no_args).once.ordered
      expect(stub).to receive(:after_renew).with(no_args).once.ordered

      subject
    end

    it 'renews service' do
      expect { subject }.to change { service.reload.renew_at }.by(1.day)
      expect(service.state_id).to eq(Billing::Service::STATE_ID_ACTIVE)
    end
  end

  shared_examples :changes_balance do
    it 'charges account' do
      expect { subject }.to change { account.reload.balance }.by(-service.renew_price)
    end

    it 'creates Billing::Transaction' do
      expect { subject }.to change { Billing::Transaction.count }.by(1)
      transaction = Billing::Transaction.last!
      expect(transaction).to have_attributes(
                               service:,
                               account:,
                               amount: service.renew_price,
                               description: described_class::DESCRIPTION
                             )
    end
  end

  shared_examples :does_not_change_balance do
    it 'does not charge account and does not create Billing::Transaction' do
      expect { subject }.not_to change {
        [account.reload.balance, Billing::Transaction.count]
      }
    end
  end

  shared_examples :suspends_service do
    it 'calls provisioning object callbacks' do
      stub = instance_double(Billing::Provisioning::Base)
      expect(service).to receive(:build_provisioning_object).and_return(stub)
      stub
      expect(stub).to receive(:before_renew).with(no_args).once.ordered
      expect(stub).to receive(:after_failed_renew).with(no_args).once.ordered
      expect(stub).to receive(:after_renew).with(no_args).once.ordered

      subject
    end

    it 'suspends service' do
      expect { subject }.not_to change { service.reload.renew_at }
      expect(service.state_id).to eq(Billing::Service::STATE_ID_SUSPENDED)
    end

    include_examples :does_not_change_balance
  end

  describe '.perform' do
    subject do
      described_class.perform(service)
    end

    let!(:service_type) do
      create(:service_type, service_type_attrs)
    end
    let(:service_type_attrs) do
      {}
    end
    let!(:account) { create(:account, account_attrs) }
    let(:account_attrs) do
      { balance: 100, min_balance: 0, max_balance: 1000 }
    end
    let!(:service) { create(:service, service_attrs) }
    let(:service_attrs) do
      {
        account:,
        type: service_type,
        renew_price: 10,
        initial_price: 0,
        renew_period_id: Billing::Service::RENEW_PERIOD_ID_DAY,
        renew_at: Time.current.beginning_of_day
      }
    end

    context 'when enough money' do
      include_examples :renews_service
      include_examples :changes_balance

      context 'when account balance will be less than min_balance' do
        let(:account_attrs) do
          super().merge balance: 100, min_balance: 90.01, max_balance: 1000
        end

        include_examples :suspends_service

        context 'when service_type with force_renew' do
          let(:service_type_attrs) do
            super().merge force_renew: true
          end

          include_examples :renews_service
          include_examples :changes_balance
        end
      end

      context 'when account balance is already greater than max_balance' do
        let(:account_attrs) do
          super().merge balance: 50, min_balance: 0, max_balance: 40
        end

        include_examples :renews_service
        include_examples :changes_balance
      end
    end

    context 'when service_renew_price is zero' do
      let(:service_attrs) do
        super().merge renew_price: 0
      end

      include_examples :renews_service
      include_examples :does_not_change_balance

      context 'when account balance is already less than min_balance' do
        let(:account_attrs) do
          super().merge balance: 50, min_balance: 60, max_balance: 1000
        end

        include_examples :renews_service
        include_examples :does_not_change_balance
      end

      context 'when account balance is already greater than max_balance' do
        let(:account_attrs) do
          super().merge balance: 50, min_balance: 0, max_balance: 40
        end

        include_examples :renews_service
        include_examples :does_not_change_balance
      end
    end

    context 'when service_renew_price is negative' do
      let(:service_attrs) do
        super().merge renew_price: -10
      end

      include_examples :renews_service
      include_examples :changes_balance

      context 'when account balance is already be less than min_balance' do
        let(:account_attrs) do
          super().merge balance: 50, min_balance: 60, max_balance: 1000
        end

        include_examples :renews_service
        include_examples :changes_balance
      end

      context 'when account balance will be greater than max_balance' do
        let(:account_attrs) do
          super().merge balance: 50, min_balance: 0, max_balance: 59.99
        end

        include_examples :suspends_service

        context 'when service_type with force_renew' do
          let(:service_type_attrs) do
            super().merge force_renew: true
          end

          include_examples :renews_service
          include_examples :changes_balance
        end
      end
    end
  end
end
