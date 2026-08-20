# frozen_string_literal: true

require 'yeti_log_component'

RSpec.describe YetiLogComponent do
  describe '.name' do
    subject { described_class.name }

    before { described_class.reset! }

    after { described_class.reset! }

    context 'when the entry point assigned the name' do
      before { described_class.name = 'delayed_job' }

      it { is_expected.to eq('delayed_job') }
    end

    context 'when the name was not assigned' do
      it 'detects the process' do
        expect(subject).to eq('rspec')
      end

      it 'detects rails console' do
        stub_const('Rails::Console', Class.new)
        expect(subject).to eq('console')
      end

      it 'detects rake task invocation' do
        allow(Rake.application).to receive(:top_level_tasks).and_return(['db:migrate'])
        expect(subject).to eq('rake')
      end
    end

    it 'memoizes the name' do
      expect(subject).to equal(described_class.name)
    end
  end
end
