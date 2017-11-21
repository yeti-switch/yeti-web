require 'spec_helper'

RSpec.describe AsyncBatchDestroyJob, type: :job do
  describe '#perform' do
    include_context :init_rateplan
    include_context :init_destination, id: 1, initial_rate: 0.3
    include_context :init_destination, id: 2, initial_rate: 0.5
    include_context :init_destination, id: 3, initial_rate: 0.7

    subject { described_class.new.perform(model_class, sql_query)}

    context 'incorrect class_name' do
      let(:model_class) { 'Fake' }

      it 'raises' do
        expect {subject}.to raise_error(NameError)
      end
    end

    context 'correct class_name' do
      let(:model_class) { 'Destination' }

      context 'no filter/selection' do
        let(:sql_query) { Destination.all.to_sql }

        it 'destroys all records' do
          expect {subject}.to change(Destination, :count).by(-3)
        end
      end

      context 'records selected' do
        let(:sql_query) { Destination.where(id: [1, 3]).to_sql }

        it 'destroys record 1 and 3' do
          expect {subject}.to change(Destination, :count).by(-2)
          expect(Destination.where(id: 2).count).to eq(1)
        end
      end

      context 'records filtered' do
        let(:sql_query) { Destination.where('initial_rate < ?', 0.5).to_sql }

        it 'destroys records with initial rate less than 0.7' do
          expect {subject}.to change(Destination, :count).by(-1)
          expect(Destination.where(id: 1).count).to eq(0)
        end
      end

    end
  end
end
