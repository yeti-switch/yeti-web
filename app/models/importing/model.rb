# frozen_string_literal: true

require 'tempfile'
require 'open3'

class Importing::Model < ActiveAdminImport::Model
  attr_reader :script_std_err

  validate :std_err_empty

  def assign_attributes(args = {}, new_record = false)
    super
    run_script if script.present?
  end

  def default_attributes
    super.merge(
      select_all: false,
      script: nil
    )
  end

  def run_script
    if script.present?
      commands = [script_path.to_s]
      commands << file.tempfile.path.to_s if file.present?
      commands << file.original_filename.shellescape.to_s if file.is_a?(ActionDispatch::Http::UploadedFile)
      Open3.popen3(commands) do |_stdin, stdout, stderr, wait_thr|
        @contents = stdout.read
        @script_std_err = stderr.read
        stdout.close
        stderr.close
        wait_thr.value
        if @contents.present?
          self.file = Tempfile.new('yeti-import')
          file << @contents
          file.rewind
        end
      end

    end
  end

  def std_err_empty
    errors.add(:base, script_std_err) if script_std_err.present?
  end

  def script_path
    File.join(GuiConfig.import_helpers_dir, script)
  end
end
