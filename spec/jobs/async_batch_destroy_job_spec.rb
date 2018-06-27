require 'spec_helper'

RSpec.describe AsyncBatchDestroyJob, type: :job do
  describe '#perform' do
    include_context :init_rateplan
    include_context :init_destination, id: 1, initial_rate: 0.3
    include_context :init_destination, id: 2, initial_rate: 0.5
    include_context :init_destination, id: 3, initial_rate: 0.7

    subject { described_class.new(model_class, sql_query, who_is).perform }

    before :each do
      stub_const('AsyncBatchDestroyJob::BATCH_SIZE', 2)
    end

    let(:admin) { create :admin_user }
    let(:who_is) { { whodunnit: admin.id, controller_info: {} } }

    context 'incorrect class_name' do
      let(:model_class) { 'Fake' }

      it { expect {subject}.to raise_error(NameError) }
    end

    context 'correct class_name' do
      let(:model_class) { 'Routing::Destination' }

      context 'no filter/selection' do
        let(:sql_query) { Routing::Destination.all.to_sql }

        it { expect {subject}.to change(Routing::Destination, :count).by(-3) }
      end

      context 'records selected' do
        let(:sql_query) { Routing::Destination.where(id: [1, 3]).to_sql }

        it { expect {subject}.to change(Routing::Destination, :count).by(-2) }
        it { expect {subject}.to change(Routing::Destination.where(id: 2), :count).by(0) }
      end

      context 'records filtered' do
        let(:sql_query) { Routing::Destination.where('initial_rate < ?', 0.5).to_sql }

        it { expect {subject}.to change(Routing::Destination, :count).by(-1) }
        it { expect {subject}.to change(Routing::Destination.where(id: 1), :count).by(-1) }
      end

    end
  end
end
