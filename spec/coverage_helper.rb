# frozen_string_literal: true

# https://github.com/irongut/CodeCoverageSummary/issues/102
module CoverageHelper
  module_function

  def start(parallel_number: nil)
    configure

    # Prevents generation result after test completed.
    # Use CoverageHelper.report to generate results.
    if parallel_number
      SimpleCov.at_exit { SimpleCov.result }
      SimpleCov.command_name "spec-#{parallel_number}"
    end

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
      add_filter '/tmp/'
      add_filter '/vendor/'
      add_filter '/Rakefile'
    end
  end
end
