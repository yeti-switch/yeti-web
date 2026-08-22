# frozen_string_literal: true

require 'semantic_logger'
require_relative 'yeti_log_component'

# Raw formatter that keeps the log record flat, for storages that can only
# index/label top level fields (VictoriaLogs stream fields, ES keyword fields):
#
#   * named tags (config.log_tags, SemanticLogger.tagged) are merged into the
#     root of the record instead of being nested under `named_tags`;
#   * static tags (YetiConfig.logs.tags) are emitted by every process, not only
#     by puma inside a request;
#   * `component` tells which process wrote the record;
#   * the logger name, `level_index`, `duration_ms`, `application` and `environment`
#     are dropped. `duration` is the number of milliseconds.
#
# Depends on semantic_logger only, so that it can be used by the processes that do
# not boot Rails as well.
class YetiLogFormatter < SemanticLogger::Formatters::Raw
  # Fields written by the formatter itself. A tag is never allowed to overwrite them.
  # `name`, `level_index` and `duration_ms` are dropped by the formatter, so a tag is
  # not allowed to bring them back either.
  RESERVED_KEYS = %i[
    host application environment component time timestamp level level_index name pid
    thread file line duration duration_ms tags named_tags message payload
    exception cause metric metric_amount
  ].freeze

  attr_reader :static_tags

  # `application` and `environment` of SemanticLogger are not emitted by default:
  # they are constants of the process, that are configured as static tags instead
  # (YetiConfig.logs.tags), so that every such field is defined in one place.
  #
  # @param static_tags [Hash] tags added to every log record.
  def initialize(static_tags: {}, log_application: false, log_environment: false, **args)
    @static_tags = static_tags.to_h { |key, value| [key.to_sym, value] }.freeze
    super(log_application:, log_environment:, **args)
  end

  # Name of the component(process) that emitted the record.
  def component
    hash[:component] = YetiLogComponent.current
  end

  # Only the name of the level is emitted: `level_index` is the same thing as a
  # number, that a log storage indexes as yet another field.
  def level
    hash[:level] = log.level
  end

  # The number of milliseconds, rounded to a microsecond: the float carries a dozen
  # meaningless digits otherwise. The Raw formatter emits it twice instead - as
  # `duration_ms` and as `duration`, the same value formatted for a human('1.658ms'),
  # that a log storage can neither sum nor compare.
  def duration
    return unless log.duration

    hash[:duration] = log.duration.round(3)
  end

  # Name of the logger is not emitted: it is whatever class happened to log the
  # record, so it means a different thing in every component - a controller class
  # for a request, `ActiveRecord` for SQL, `Delayed::Worker` for a job, `Rails` for
  # everything that logs through Rails.logger. Use tags for anything to filter by.
  def name; end

  # Static and named tags, merged into the top level of the record.
  # Named tags win over static ones, both lose to the fields of the record itself.
  def named_tags
    merge_tags(static_tags)
    merge_tags(log.named_tags)
  end

  def call(log, logger)
    super
    component
    hash
  end

  private

  def merge_tags(tags)
    tags&.each do |key, value|
      key = key.to_sym
      hash[key] = value unless RESERVED_KEYS.include?(key)
    end
  end
end
