require 'tempfile'
require 'open3'

class Importing::Model < ActiveAdminImport::Model

  attr_reader :script_std_err

  validate :std_err_empty

  def assign_attributes(args = {}, new_record = false)
    super
    run_script if self.script.present?
  end

  def default_attributes
    super.merge({
                    select_all: false,
                    script: nil,
                    unique_columns_values: [],
                })
  end


  def run_script
    if self.script.present?
      commands = ["#{script_path}"]
      commands << "#{file.tempfile.path}" if self.file.present?
      commands << "#{file.original_filename.shellescape}" if self.file.is_a?(ActionDispatch::Http::UploadedFile)
      Open3.popen3("#{commands.join(" ")}") do |stdin, stdout, stderr, wait_thr|
        @contents = stdout.read
        @script_std_err = stderr.read
        stdout.close
        stderr.close
        wait_thr.value
        if @contents.present?
          self.file = Tempfile.new("yeti-import")
          self.file << @contents
          self.file.rewind
        end

      end

    end
  end

  def std_err_empty
    self.errors.add(:base, self.script_std_err) unless self.script_std_err.blank?
  end

  def script_path
    File.join(GuiConfig.import_helpers_dir, script)
  end

end