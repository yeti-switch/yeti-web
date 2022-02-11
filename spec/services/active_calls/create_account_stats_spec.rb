# frozen_string_literal: true

RSpec.describe ActiveCalls::CreateAccountStats, '.call' do
  subject do
    ActiveCalls::CreateAccountStats.call(service_params)
  end

  let(:service_params) do
    {
      customer_calls: customer_calls,
      vendor_calls: vendor_calls,
      current_time: 1.minute.ago
    }
  end
  let!(:accounts) do
    FactoryBot.create_list(:account, 10)
  end

  context 'without calls' do
    let(:customer_calls) do
      {}
    end
    let(:vendor_calls) do
      {}
    end

    it 'creates correct stats' do
      expect { subject }.to change { Stats::ActiveCallAccount.count }.by(accounts.size)

      accounts.each do |account|
        stats = Stats::ActiveCallAccount.where(account_id: account.id).to_a
        expect(stats.size).to eq(1)
        expect(stats.first).to have_attributes(
                                 terminated_count: 0,
                                 originated_count: 0,
                                 created_at: be_within(1).of(service_params[:current_time])
                               )
      end
    end
  end

  context 'with calls' do
    let(:customer_calls) do
      {
        accounts.first.id.to_s => [double, double],
        accounts.second.id.to_s => [double]
      }
    end
    let(:vendor_calls) do
      {
        accounts.second.id.to_s => [double, double, double],
        accounts.third.id.to_s => [double, double, double, double]
      }
    end

    it 'creates correct stats' do
      expect { subject }.to change { Stats::ActiveCallAccount.count }.by(accounts.size)

      acc1_stats = Stats::ActiveCallAccount.where(account_id: accounts.first.id).to_a
      expect(acc1_stats.size).to eq(1)
      expect(acc1_stats.first).to have_attributes(
                                    terminated_count: 0,
                                    originated_count: 2,
                                    created_at: be_within(1).of(service_params[:current_time])
                                  )

      acc2_stats = Stats::ActiveCallAccount.where(account_id: accounts.second.id).to_a
      expect(acc2_stats.size).to eq(1)
      expect(acc2_stats.first).to have_attributes(
                                    terminated_count: 3,
                                    originated_count: 1,
                                    created_at: be_within(1).of(service_params[:current_time])
                                  )

      acc3_stats = Stats::ActiveCallAccount.where(account_id: accounts.third.id).to_a
      expect(acc3_stats.size).to eq(1)
      expect(acc3_stats.first).to have_attributes(
                                    terminated_count: 4,
                                    originated_count: 0,
                                    created_at: be_within(1).of(service_params[:current_time])
                                  )

      other_accounts = accounts - [accounts.first, accounts.second, accounts.third]
      other_accounts.each do |account|
        stats = Stats::ActiveCallAccount.where(account_id: account.id).to_a
        expect(stats.size).to eq(1)
        expect(stats.first).to have_attributes(
                                 terminated_count: 0,
                                 originated_count: 0,
                                 created_at: be_within(1).of(service_params[:current_time])
                               )
      end
    end
  end
end
