# frozen_string_literal: true

# == Schema Information
#
# Table name: guiconfig
#
#  id                              :integer(4)       not null, primary key
#  active_calls_autorefresh_enable :boolean          default(FALSE), not null
#  active_calls_require_filter     :boolean          default(TRUE), not null
#  active_calls_show_chart         :boolean          default(FALSE), not null
#  cdr_unload_dir                  :string
#  cdr_unload_uri                  :string
#  drop_call_if_lnp_fail           :boolean          default(FALSE), not null
#  import_helpers_dir              :string           default("/tmp")
#  import_max_threads              :integer(4)       default(4), not null
#  lnp_cache_ttl                   :integer(4)       default(10800), not null
#  lnp_e2e_timeout                 :integer(2)       default(1000), not null
#  max_call_duration               :integer(4)       default(7200), not null
#  max_records                     :integer(4)       default(100500), not null
#  quality_control_min_calls       :integer(4)       default(100), not null
#  quality_control_min_duration    :integer(4)       default(3600), not null
#  random_disconnect_enable        :boolean          default(FALSE), not null
#  random_disconnect_length        :integer(4)       default(7000), not null
#  registrations_require_filter    :boolean          default(TRUE), not null
#  rows_per_page                   :string           default("50,100"), not null
#  short_call_length               :integer(4)       default(15), not null
#  termination_stats_window        :integer(4)       default(24), not null
#  web_url                         :string           default("http://127.0.0.1"), not null
#
RSpec.describe GuiConfig, type: :model do
  describe '.import_scripts' do
    subject { described_class.import_scripts }

    context 'when raised Errno::ENOENT' do
      before do
        allow(Dir).to receive(:entries).and_raise(Errno::ENOENT.new('No such file or directory'))
      end

      it 'should return empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when there are scripts in the import dir' do
      let(:import_dir) { '/fake/import/dir' }
      let(:script_file) { 'my_script.sh' }
      let(:script_path) { File.join(import_dir, script_file) }

      before do
        allow(described_class).to receive(:import_helpers_dir).and_return(import_dir)
        allow(Dir).to receive(:entries).with(import_dir).and_return(['.', '..', script_file])
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with(script_path).and_return(true)
      end

      context 'when script writes its name to stderr' do
        before do
          allow(Open3).to receive(:capture3).with(script_path)
                                            .and_return(['', "Script Title\n", double('status')])
        end

        it 'uses first line of stderr as script name' do
          expect(subject).to eq([['Script Title', script_file]])
        end
      end

      context 'when script writes multiple lines to stderr' do
        before do
          allow(Open3).to receive(:capture3).with(script_path)
                                            .and_return(['', "First Line\nSecond Line\n", double('status')])
        end

        it 'uses only the first line of stderr as script name' do
          expect(subject).to eq([['First Line', script_file]])
        end
      end

      context 'when script writes nothing to stderr' do
        before do
          allow(Open3).to receive(:capture3).with(script_path)
                                            .and_return(['some output', '', double('status')])
        end

        it 'uses filename as script name when stderr is empty' do
          expect(subject).to eq([[script_file, script_file]])
        end
      end
    end
  end
end
