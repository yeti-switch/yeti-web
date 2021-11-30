# frozen_string_literal: true

RSpec.describe AsyncBatchUpdateJob, type: :job do
  describe '#perform' do
    include_context :init_rateplan
    include_context :init_rate_group
    include_context :init_destination, id: 1, initial_rate: 0.3
    include_context :init_destination, id: 2, initial_rate: 0.5
    include_context :init_destination, id: 3, initial_rate: 0.7

    subject { described_class.perform_now(model_class, sql_query, changes, who_is) }

    before :each do
      stub_const('AsyncBatchUpdateJob::BATCH_SIZE', 2)
    end

    let(:admin) { create :admin_user }
    let(:who_is) { { whodunnit: admin.id, controller_info: {} } }

    context 'incorrect class_name' do
      let(:model_class) { 'Fake' }

      it { expect { subject }.to raise_error(NameError) }
    end

    context 'correct class_name' do
      let(:model_class) { 'Routing::Destination' }

      context 'incorrect changes' do
        let(:changes) { { rate_group_id: 2000 } } # there is no rategroup with id=2000
        let(:sql_query) { Routing::Destination.all.to_sql }

        it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'correct changes' do
        let(:changes) { { prefix: '300', reject_calls: false } }

        context 'no filter/selection' do
          let(:sql_query) { Routing::Destination.all.to_sql }

          it { expect { subject }.to change(Routing::Destination.where(prefix: '300', reject_calls: false), :count).by(3) }
        end

        context 'records selected' do
          let(:sql_query) { Routing::Destination.where(id: [1, 3]).to_sql }

          it { expect { subject }.to change(Routing::Destination.where(prefix: '300', reject_calls: false), :count).by(2) }
          it { expect { subject }.to change(Routing::Destination.where(id: 2, prefix: 300), :count).by(0) }
        end

        context 'records filtered' do
          let(:sql_query) { Routing::Destination.where('initial_rate < ?', 0.5).to_sql }

          it { expect { subject }.to change(Routing::Destination.where(prefix: '300', reject_calls: false), :count).by(1) }
          it { expect { subject }.to change(Routing::Destination.where(id: 1, prefix: 300), :count).by(1) }
        end

        context 'records filtered and ordering' do
          let(:sql_query) { Routing::Destination.where('initial_rate < ?', 0.5).order(:id).to_sql }

          it { expect { subject }.to change(Routing::Destination.where(prefix: '300', reject_calls: false), :count).by(1) }
          it { expect { subject }.to change(Routing::Destination.where(id: 1, prefix: 300), :count).by(1) }
        end

        context 'records filtered and ordering by attribute to be updated' do
          let(:sql_query) { Routing::Destination.where('initial_rate < ?', 0.5).order(:prefix).to_sql }

          it { expect { subject }.to change(Routing::Destination.where(prefix: '300', reject_calls: false), :count).by(1) }
          it { expect { subject }.to change(Routing::Destination.where(id: 1, prefix: 300), :count).by(1) }
        end
      end

      context 'test LogicLog class' do
        let(:sql_query) { Routing::Destination.all.to_sql }

        context 'should write record about' do
          let(:changes) { { next_interval: 4 } }
          it 'success performed job' do
            expect { subject }.to change(LogicLog, :count).by 1
            expect(LogicLog.last.msg).to start_with 'Success'
          end
        end

        context 'when the job raise an error' do
          let(:changes) { { next_interval: 'string' } }
          it 'error performed job' do
            expect do
              expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
            end.to change(LogicLog, :count).by 1
            expect(LogicLog.last.msg).to start_with 'Error'
          end
        end
      end

      context 'with routing tags changes' do
        let!(:routing_tag_ids) { create_list(:routing_tag, 3).map { |tag| tag.id.to_s } }
        let(:changes) { { routing_tag_ids: routing_tag_ids } }

        context 'no filter/selection' do
          let(:sql_query) { Routing::Destination.all.to_sql }

          it { expect { subject }.to change(Routing::Destination.where(routing_tag_ids: routing_tag_ids), :count).by(3) }
        end

        context 'records selected' do
          let(:sql_query) { Routing::Destination.where(id: [1, 3]).to_sql }

          it { expect { subject }.to change(Routing::Destination.where(routing_tag_ids: routing_tag_ids), :count).by(2) }
          it { expect { subject }.to change(Routing::Destination.where(id: 2, routing_tag_ids: []), :count).by(0) }
        end

        context 'records filtered' do
          let(:sql_query) { Routing::Destination.where('initial_rate < ?', 0.5).to_sql }

          it { expect { subject }.to change(Routing::Destination.where(routing_tag_ids: routing_tag_ids), :count).by(1) }
          it { expect { subject }.to change(Routing::Destination.where(id: 1, routing_tag_ids: routing_tag_ids), :count).by(1) }
        end

        context 'records filtered and ordering' do
          let(:sql_query) { Routing::Destination.where('initial_rate < ?', 0.5).order(:id).to_sql }

          it { expect { subject }.to change(Routing::Destination.where(routing_tag_ids: routing_tag_ids), :count).by(1) }
          it { expect { subject }.to change(Routing::Destination.where(id: 1, routing_tag_ids: routing_tag_ids), :count).by(1) }
        end
      end
    end

    context 'with CustomersAuth' do
      let(:model_class) { 'CustomersAuth' }

      let!(:customer_auths) do
        create_list(:customers_auth, 3, capacity: 1)
      end

      let(:changes) { { capacity: 124 } }
      let(:sql_query) { CustomersAuth.all.to_sql }

      it 'updates successfully' do
        expect { subject }.to change {
          CustomersAuth.where(capacity: 124).count
        }.from(0).to(customer_auths.size)
      end

      include_examples :increments_customers_auth_state, by: 3
    end
  end
end
