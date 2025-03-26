# frozen_string_literal: true

RSpec.describe AsyncBatchDestroyJob, type: :job do
  describe '#perform' do
    include_context :init_rateplan
    include_context :init_rate_group
    include_context :init_destination, id: 1, initial_rate: 0.3
    include_context :init_destination, id: 2, initial_rate: 0.5
    include_context :init_destination, id: 3, initial_rate: 0.7

    subject { described_class.perform_now(model_class, sql_query, who_is) }

    before :each do
      stub_const('AsyncBatchDestroyJob::BATCH_SIZE', 2)
    end

    let(:admin) { create :admin_user }
    let(:who_is) { { whodunnit: admin.id, controller_info: {} } }

    context 'incorrect class_name' do
      let(:model_class) { 'Fake' }

      it { expect { subject }.to raise_error(NameError) }
    end

    context 'correct class_name' do
      let(:model_class) { 'Routing::Destination' }

      context 'no filter/selection' do
        let(:sql_query) { Routing::Destination.all.to_sql }

        it { expect { subject }.to change(Routing::Destination, :count).by(-3) }
      end

      context 'records selected' do
        let(:sql_query) { Routing::Destination.where(id: [1, 3]).to_sql }

        it { expect { subject }.to change(Routing::Destination, :count).by(-2) }
        it { expect { subject }.to change(Routing::Destination.where(id: 2), :count).by(0) }
      end

      context 'records filtered' do
        let(:sql_query) { Routing::Destination.where('initial_rate < ?', 0.5).to_sql }

        it { expect { subject }.to change(Routing::Destination, :count).by(-1) }
        it { expect { subject }.to change(Routing::Destination.where(id: 1), :count).by(-1) }
      end

      context 'test LogicLog class' do
        let!(:contractor) { create :vendor }
        let!(:contractor_alone) { create :vendor }
        let!(:gateway_group) { create :gateway_group, vendor: contractor }
        let(:model_class) { 'Contractor' }

        context 'should write record about' do
          let(:sql_query) { Contractor.where(id: contractor_alone.id).to_sql }
          it 'success performed job' do
            expect { subject }.to change(LogicLog, :count).by 1
            expect(LogicLog.last.msg).to start_with 'Success'
          end
        end

        context 'when the job raise an error' do
          let(:sql_query) { Contractor.all.to_sql }
          it 'error performed job' do
            expect do
              expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
            end.to change(LogicLog, :count).by 1
            expect(LogicLog.last.msg).to start_with 'Error'
          end
        end
      end

      context 'when record cannot be destroyed' do
        let(:model_class) { 'Dialpeer' }

        let!(:dialpeers) { FactoryBot.create_list(:dialpeer, 4) }
        let!(:item) do
          FactoryBot.create(:rate_management_pricelist_item, :with_pricelist, :filed_from_project, dialpeer: dialpeers.last)
        end
        let(:sql_query) { Dialpeer.all.to_sql }

        it 'should raise validation error' do
          error_message = "Dialpeer ##{dialpeers.last.id} can't be deleted: Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{item.pricelist_id}"
          expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed, error_message)

          dialpeers.first(2).each do |dialpeer|
            expect(Dialpeer).not_to be_exists(dialpeer.id)
          end

          dialpeers.last(2).each do |dialpeer|
            expect(Dialpeer).to be_exists(dialpeer.id)
          end
        end
      end

      context 'context' do
        let(:model_class) { 'Account' }
        let(:sql_query) { Account.all.to_sql }

        before do
          account = FactoryBot.create(:account, :with_customer)
          FactoryBot.create(:rate_management_pricelist_item, :with_pricelist, account: account)
        end

        it 'should' do
          expect { subject }.to change(Account, :count).by(-1)
        end
      end
    end
  end
end
