require 'spec_helper'

RSpec.describe AsyncBatchUpdateJob, type: :job do
  describe '#perform' do
    include_context :init_rateplan
    include_context :init_destination, id: 1, initial_rate: 0.3
    include_context :init_destination, id: 2, initial_rate: 0.5
    include_context :init_destination, id: 3, initial_rate: 0.7

    subject { described_class.new.perform(model_class, sql_query, changes)}

    context 'incorrect class_name' do
      let(:model_class) { 'Fake' }

      it 'raises' do
        expect {subject}.to raise_error(NameError)
      end
    end

    context 'correct class_name' do
      let(:model_class) { 'Destination' }

      context 'incorrect changes' do
        let(:changes) { {rateplan_id: 2000} } #there is no rateplan with id=2000
        let(:sql_query) { Destination.all.to_sql }

        it 'does not update to incorrect values' do
          expect {subject}.to change(Destination.where(rateplan_id: 2000), :count).by(0)
        end
      end

      context 'correct changes' do
        let(:changes) { {prefix: '300', reject_calls: false} }

        context 'no filter/selection' do
          let (:sql_query) { Destination.all.to_sql }

          it 'changes all records' do
            expect {subject}.to change(Destination.where(prefix: '300', reject_calls: false), :count).by(3)
          end
        end

        context 'records selected' do
          let(:sql_query) { Destination.where(id: [1, 3]).to_sql }

          it 'changes records 1 and 3' do
            expect {subject}.to change(Destination.where(prefix: '300', reject_calls: false), :count).by(2)
            expect(Destination.where(id: 2, prefix: 300).count).to eq(0)
          end
        end

        context 'records filtered' do
          let(:sql_query) { Destination.where('initial_rate < ?', 0.5).to_sql }

          it 'changes records with initial rate less than 0.5' do
            expect {subject}.to change(Destination.where(prefix: '300', reject_calls: false), :count).by(1)
            expect(Destination.where(id: 1, prefix: 300).count).to eq(1)
          end
        end
      end
    end

  end
end
