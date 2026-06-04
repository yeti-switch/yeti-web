# frozen_string_literal: true

require 'tempfile'
require 'open3'

class Importing::Model < ActiveAdminImport::Model
  attr_reader :script_std_err

  validate :std_err_empty
  validate :quote_char_single_character

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
      @contents, @script_std_err, _status = Open3.capture3(*commands)
      if @contents.present?
        self.file = Tempfile.new('yeti-import')
        file << @contents
        file.rewind
      end

    end
  end

  def std_err_empty
    errors.add(:base, script_std_err) if script_std_err.present?
  end

  # CSV requires quote_char to be nil or a single character. The import gem only
  # strips nil/empty values from csv_options, so a multi-character value (e.g. an
  # accidental "") would otherwise reach CSV.parse and raise an unhandled
  # ArgumentError (HTTP 500). Surface it as a form error instead.
  def quote_char_single_character
    csv_options = attributes[:csv_options]
    quote_char = csv_options.is_a?(Hash) ? (csv_options[:quote_char] || csv_options['quote_char']) : nil
    return if quote_char.blank? || quote_char.to_s.length == 1

    errors.add(:base, 'CSV quote char must be nil or a single character')
  end

  def script_path
    File.join(GuiConfig.import_helpers_dir, script)
  end
end
