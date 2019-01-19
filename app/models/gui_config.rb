# frozen_string_literal: true

# == Schema Information
#
# Table name: guiconfig
#
#  rows_per_page                   :string           default("50,100"), not null
#  id                              :integer          not null, primary key
#  cdr_unload_dir                  :string
#  cdr_unload_uri                  :string
#  max_records                     :integer          default(100500), not null
#  import_max_threads              :integer          default(4), not null
#  import_helpers_dir              :string           default("/tmp")
#  cdr_archive_delay               :integer          default(4), not null
#  cdr_remove_delay                :integer          default(120), not null
#  active_calls_require_filter     :boolean          default(TRUE), not null
#  registrations_require_filter    :boolean          default(TRUE), not null
#  active_calls_show_chart         :boolean          default(FALSE), not null
#  active_calls_autorefresh_enable :boolean          default(FALSE), not null
#  max_call_duration               :integer          default(7200), not null
#  random_disconnect_enable        :boolean          default(FALSE), not null
#  random_disconnect_length        :integer          default(7000), not null
#  drop_call_if_lnp_fail           :boolean          default(FALSE), not null
#  short_call_length               :integer          default(15), not null
#  termination_stats_window        :integer          default(24), not null
#  lnp_cache_ttl                   :integer          default(10800), not null
#  quality_control_min_calls       :integer          default(100), not null
#  quality_control_min_duration    :integer          default(3600), not null
#  lnp_e2e_timeout                 :integer          default(1000), not null
#  web_url                         :string           default("http://127.0.0.1"), not null
#

class GuiConfig < ActiveRecord::Base
  self.table_name = 'guiconfig'

  has_paper_trail class_name: 'AuditLogItem'

  SETTINGS_NAMES = %i[rows_per_page
                      cdr_unload_dir
                      cdr_unload_uri
                      cdr_archive_delay
                      cdr_remove_delay
                      max_records
                      import_max_threads
                      import_helpers_dir
                      active_calls_require_filter
                      registrations_require_filter
                      active_calls_show_chart
                      active_calls_autorefresh_enable
                      max_call_duration
                      random_disconnect_enable
                      random_disconnect_length
                      drop_call_if_lnp_fail
                      lnp_cache_ttl
                      lnp_e2e_timeout
                      short_call_length
                      termination_stats_window
                      quality_control_min_calls
                      quality_control_min_duration].freeze

  singleton_class.class_eval do
    SETTINGS_NAMES.each do |key|
      define_method key do
        instance.send(key)
      end
    end
  end

  def self.instance
    first || new
  end

  def self.per_page
    rows_per_page.split(',').map(&:to_i).uniq
  end

  def self.import_scripts(allowed_file_prefix = '')
    import_dir = import_helpers_dir
    scripts = []
    begin
      Dir.entries(import_dir).each do |f|
        path = File.join(import_dir, f)
        next unless File.file?(path) && (allowed_file_prefix.blank? || f.start_with?(allowed_file_prefix))

        # Retrieve Script Title from stderror output of this script, otherwise use File Name
        std = Open3.popen3(path)
        script_name = std[2].gets || f
        scripts << [script_name.chomp, f]
      end
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
    end
    scripts
  end

  def display_name
    id.to_s
  end

  FILTER_MISSED_TEXT = 'Please, specify at least 1 filter'
end
