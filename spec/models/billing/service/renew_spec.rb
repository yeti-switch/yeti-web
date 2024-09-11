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

    it 'does not charge account' do
      expect { subject }.not_to change { account.reload.balance }
    end

    it 'does not create Billing::Transaction' do
      expect { subject }.to change { Billing::Transaction.count }.by(0)
    end
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
    let!(:account_attrs) do
      { balance: 100, min_balance: 0, max_balance: 1000 }
    end
    let!(:service) { create(:service, service_attrs) }
    let!(:service_attrs) do
      {
        account:,
        type: service_type,
        renew_price: 10,
        initial_price: 0,
        renew_period_id: Billing::Service::RENEW_PERIOD_ID_DAY,
        renew_at: Time.current.beginning_of_day
      }
    end

    context 'test' do
      let(:service_type_attrs) do
        super().merge provisioning_class: 'Billing::Provisioning::FreeMinutes',
                      variables: { prefixes: [] }
      end
      let(:service_attrs) do
        super().merge variables: {
          "prefixes": [
            {
              "prefix": '380',
              "exclude": false,
              "duration": 3600
            }
          ]
        }
      end

      include_examples :renews_service
    end

    context 'when enough money' do
      include_examples :renews_service

      context 'when account balance will be less than min_balance' do
        let!(:account_attrs) do
          super().merge min_balance: 90.01
        end

        include_examples :suspends_service
      end
    end

    context 'when not enough money' do
      let!(:account_attrs) do
        super().merge balance: 9.99
      end

      context 'when service_type with force_renew' do
        let(:service_type_attrs) do
          super().merge force_renew: true
        end

        include_examples :renews_service
      end
    end
  end
end
