# frozen_string_literal: true

RSpec.describe Importing::Model do
  describe '#run_script' do
    let(:script_name) { 'test_script.sh' }
    let(:import_dir) { '/fake/import/dir' }
    let(:script_path) { File.join(import_dir, script_name) }

    before do
      allow(GuiConfig).to receive(:import_helpers_dir).and_return(import_dir)
    end

    subject { described_class.new(script: script_name) }

    context 'when script writes to stdout only' do
      before do
        allow(Open3).to receive(:capture3).with(script_path)
                                          .and_return(["imported content\n", '', double('status')])
      end

      it 'sets file contents from stdout' do
        expect(subject.file).to be_present
      end

      it 'sets blank script_std_err' do
        expect(subject.script_std_err).to be_blank
      end
    end

    context 'when script writes to stderr' do
      before do
        allow(Open3).to receive(:capture3).with(script_path)
                                          .and_return(['', "script error\n", double('status')])
      end

      it 'captures stderr output' do
        expect(subject.script_std_err).to eq("script error\n")
      end

      it 'adds a validation error from stderr' do
        model = subject
        model.valid?
        expect(model.errors[:base]).to include("script error\n")
      end
    end

    context 'when script writes to both stdout and stderr' do
      before do
        allow(Open3).to receive(:capture3).with(script_path)
                                          .and_return(["imported content\n", "warning message\n", double('status')])
      end

      it 'captures both stdout and stderr without deadlock' do
        model = subject
        expect(model.file).to be_present
        expect(model.script_std_err).to eq("warning message\n")
      end
    end
  end
end
