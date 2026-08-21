# frozen_string_literal: true

require 'yeti_log_component'

RSpec.describe YetiLogComponent do
  describe '.current' do
    subject { described_class.current }

    before { described_class.reset! }

    after { described_class.reset! }

    context 'when the entry point assigned the name' do
      before { described_class.current = 'delayed_job' }

      it { is_expected.to eq('delayed_job') }

      it 'is frozen, so that it cannot be changed by mutating the assigned string' do
        expect(subject).to be_frozen
      end
    end

    it 'keeps no reference to the assigned string' do
      name = +'delayed_job'
      described_class.current = name
      name << '_mutated'
      expect(described_class.current).to eq('delayed_job')
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
      expect(subject).to equal(described_class.current)
    end
  end
end
