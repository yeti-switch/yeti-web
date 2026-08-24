# frozen_string_literal: true

class BackgroundTaskDecorator < Draper::Decorator
  delegate_all
  decorates BackgroundTask

  # The same value the `job` tag of the logs carries, see Delayed::LogJobTagsPlugin.
  def name
    payload_object ? Delayed::JobName.call(payload_object) : Delayed::JobName.from_handler(model.handler)
  end

  def args
    return '-' unless payload_object.respond_to?(:job_data)

    payload_object.job_data['arguments'].join("\n,")
  end

  # A row whose handler does not deserialize - a job class that a deploy has renamed or
  # removed - must not break the page, that is the only way to see and to delete it.
  # Delayed::LogJobTagsPlugin skips the same rows for the same reason.
  #
  # @return [Object, nil]
  def payload_object
    return @payload_object if defined?(@payload_object)

    @payload_object =
      begin
        model.payload_object
      rescue Delayed::DeserializationError
        nil
      end
  end

  def args_short
    h.short_text(args, max_length: 50)
  end

  def last_error_short
    h.short_text(model.last_error, max_length: 50)
  end
end
