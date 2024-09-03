# frozen_string_literal: true

# https://github.com/irongut/CodeCoverageSummary/issues/102
module CoverageHelper
  module_function

  def start(parallel_number: nil)
    configure

    # Prevents generation result after test completed.
    # Use CoverageHelper.report to generate results.
    if parallel_number
      SimpleCov.at_exit {
        puts 'SimpleCov gathering results'
        SimpleCov.result
      }
      SimpleCov.command_name "spec-#{parallel_number}"
    end

    puts "Starting SimpleCov (parallel_number=#{parallel_number})"
    SimpleCov.start 'rails'
  end

  def parallel_report
    configure

    project_root = File.expand_path('../', __dir__)
    SimpleCov.collate Dir[File.join(project_root, 'coverage/*/coverage/.resultset.json')], 'rails'
  end

  def configure
    require 'simplecov'
    require 'simplecov-cobertura'

    SimpleCov.singleton_class.prepend(Module.new do
      def final_result_process?
        # if PARALLEL_TEST_GROUPS=1, we are running tests in parallel but only one group,
        # in this case the result is final and we can process it.
        res = super || ENV['PARALLEL_TEST_GROUPS'] == '1'
        puts "SimpleCov.final_result_process? => #{res}"
        res
      end

      def wait_for_other_processes
        # if PARALLEL_TEST_GROUPS=1, we are running tests in parallel but only one group,
        # in this case we don't need to wait for other processes.
        return if ENV['PARALLEL_TEST_GROUPS'] == '1'

        res = super
        puts "SimpleCov.wait_for_other_processes => #{res}"
        res
      end

      def ready_to_process_results?
        res = super
        puts "SimpleCov.ready_to_process_results? => #{res}"
        res
      end

      def process_results_and_report_error
        res = super
        puts "SimpleCov.process_results_and_report_error => #{res}"
        res
      end

      def process_result(result)
        res = super
        puts "SimpleCov.process_result(result) => #{res}"
        res
      end
    end)

    SimpleCov::ResultMerger.singleton_class.prepend(Module.new do
      def store_result(result)
        res = super
        puts "SimpleCov::ResultMerger.store_result(result) => #{res}"
        puts "SimpleCov::ResultMerger.resultset_path => #{resultset_path}"
        puts "File.exists?(resultset_path) => #{File.exist?(resultset_path)}"
        res
      end
    end)

    SimpleCov.configure do
      enable_coverage :branch

      formatter SimpleCov::Formatter::CoberturaFormatter

      add_group 'Admin Pages', 'app/admin/'
      add_group 'Decorators', 'app/decorators/'
      add_group 'Forms', 'app/forms/'
      add_group 'Policies', 'app/policies/'
      add_group 'JSONAPI Resources', 'app/resources/'
      add_group 'Services', 'app/services/'
      add_group 'Validators', 'app/validators/'
      add_group 'Libs', 'app/lib/'
      add_group 'Patches', 'lib/'

      add_filter '/bin/'
      add_filter '/ci/'
      add_filter '/config/'
      add_filter '/db/'
      add_filter '/debian/'
      add_filter '/doc/'
      add_filter '/log/'
      add_filter '/pgq-processors/'
      add_filter '/public/'
      add_filter '/script/'
      add_filter '/spec/'
      add_filter '/swagger/'
      add_filter '/tmp/'
      add_filter '/vendor/'
      add_filter '/Rakefile'
    end
  end
end
