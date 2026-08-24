# frozen_string_literal: true

# Tags every record logged within the block with the given fields.
#
# SemanticLogger keeps a Hash as named tags, that YetiLogFormatter merges into the root
# of the log record. Any other tagged logger - Rails.logger is an ActiveSupport::TaggedLogging
# when SKIP_RAILS_SEMANTIC_LOGGER=true - has no named tags and inspects the Hash into the
# line itself(`[{job: "Jobs::CallsMonitoring"}]`), so there the values are tagged one by one.
#
# Depends on no gem, so that the processes that do not boot Rails can use it as well.
module YetiLogTags
  module_function

  # @param logger [#tagged, nil] nothing is tagged when it is nil or logs no tags.
  # @param tags [Hash] fields added to every record logged within the block.
  def tagged(logger, tags, &block)
    return yield if tags.empty? || logger.nil? || !logger.respond_to?(:tagged)
    return logger.tagged(tags, &block) if named_tags?(logger)

    logger.tagged(*tags.values, &block)
  end

  # @return [Boolean]
  def named_tags?(logger)
    defined?(::SemanticLogger::Base) && logger.is_a?(::SemanticLogger::Base)
  end
end
