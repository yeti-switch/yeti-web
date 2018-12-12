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
    let!(:account) { create(:account, package_id: nil) }

    subject do
      account.package = package
      account.save
    end

    context 'when package configurations exists' do
      let(:package) { create(:package, :with_two_configurations) }
      let(:new_counters) { Billing::AccountPackageCounter.all }

      # account_package_counters will store counter of a minutes by directions
      it 'copies package_configs into account_package_counters' do
        expect { subject }.to change { Billing::AccountPackageCounter.count }.by(2)

        expect(new_counters.pluck(:account_id).uniq).to eq [account.id]
        expect(new_counters.pluck(:prefix)).to eq(Billing::PackageConfig.pluck(:prefix))
        expect(new_counters.pluck(:duration)).to eq([0,0])
        expect(new_counters.pluck(:expired_at).uniq).to eq([nil])
      end

      # charge account, regardless of number of configurations copied(even zero)
      xit 'creates new Payment' do
        # pending
      end
    end

    context 'when none configurations exists' do
      # it 'creates new Payment' do
    end

    context 'when account has another package assigned' do
      # TODO: what to do?
    end
  end

end
