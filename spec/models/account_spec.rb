require 'spec_helper'

describe Account, type: :model do

  it do
    should validate_numericality_of(:origination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    should validate_numericality_of(:termination_capacity).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
  end

  context '#destroy' do
    let!(:account) { create(:account) }

    subject do
      account.destroy!
    end

    context 'wihtout linked ApiAccess records' do
      let!(:api_access) { create(:api_access) }


      it 'removes Account successfully' do
        expect { subject }.to change { described_class.count }.by(-1)
      end

      it 'keeps ApiAccess records' do
        expect { subject }.not_to change { System::ApiAccess.count }
      end
    end

    context 'when Account is linked from ApiAccess' do
      let!(:api_access) { create(:api_access) }
      let(:accounts) { create_list(:account, 3, contractor: api_access.customer) }

      before do
        api_access.update!(account_ids: accounts.map(&:id))
      end

      subject do
        accounts.second.destroy!
      end

      it 'update relaated ApiAccess#account_ids (removes second element from array)' do
        expect { subject }.to change {
          api_access.reload.account_ids
        }.from(accounts.map(&:id)).to(accounts.map(&:id).values_at(0,2))
      end
    end

    context 'when Account has Payments' do
      let!(:p1) do
        create(:payment, account: account)
      end
      let!(:p2) do
        create(:payment) # for another account
      end

      it 'removes all related Payments' do
        expect { subject }.to change {
          Payment.pluck(:id)
        }.from([p1.id, p2.id]).to([p2.id])
      end
    end

    context 'when Account has related CustomersAuth' do
      let(:customers_auth) { create(:customers_auth) }
      let(:account) { customers_auth.account }

      it 'throw error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context 'when Account has related Dialpeer' do
      let(:dialpeer) { create(:dialpeer) }
      let(:account) { dialpeer.account }

      it 'throw error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

  end

  # Billing packages
  #
  describe 'assign Package' do
    let!(:account) do
      create(:account, balance: 1000, package_id: nil)
    end

    let(:package) do
      create(:package, :with_two_configurations, price: 110.00)
    end

    subject do
      account.package = package
      account.save
    end

    context 'when package configurations exists' do
      let(:new_counters) { Billing::AccountPackageCounter.all }

      # account_package_counters will store counter of a minutes by directions
      it 'copies package_configs into account_package_counters' do
        expect { subject }.to change { Billing::AccountPackageCounter.count }.by(2)

        expect(new_counters.to_a).to match (
          [
            have_attributes(account_id: account.id,
                            prefix: Billing::PackageConfig.first.prefix,
                            duration: 0,
                            expired_at: nil),
            have_attributes(account_id: account.id,
                            prefix: Billing::PackageConfig.second.prefix,
                            duration: 0,
                            expired_at: nil)
          ]
        )
      end

      # charge account for a `package.price`
      it 'creates new Payment' do
        subject
        expect(Payment.last).to have_attributes(
          account_id: account.id,
          amount: -package.price,
          notes: nil
        )
      end

      it 'raise error when not enough money and do nothing' do
        account.update(min_balance: 0)
        account.update(balance: 109.99)

        expect {
          expect(subject).to be_falsey
          expect(account.errors[:package_id][0]).to eq('Not enough money for package configuration')
        }.not_to change {
          [Payment.count, Billing::AccountPackageCounter.count]
        }
      end

      it 'raise error when not exceeds min_balance' do
        account.update(min_balance: -0.02) # (109.99 - 110.00) > -0.02
        account.update(balance: 109.99)

        expect(subject).to be_truthy
      end
    end

    context 'when account has another package assigned' do
      before do
        subject
      end

      let(:another_package) do
        create(:package, :with_two_configurations, price: 5)
      end

      it 'forbid change of package_id directly' do
        account.package_id = another_package.id
        expect {
          account.save!
        }.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Package can't be changed during billing period")
      end
    end

    context 'when none configurations exists' do
      # it 'creates new Payment' do
    end
  end

end
