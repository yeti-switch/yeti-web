# frozen_string_literal: true

class BackgroundTaskDecorator < Draper::Decorator
  delegate_all
  decorates BackgroundTask

  # The same value the `job` tag of the logs carries, see Delayed::LogJobTagsPlugin.
  def name
    Delayed::JobName.call(model.payload_object)
  end

  def args
    return '-' unless model.payload_object.respond_to?(:job_data)

    model.payload_object.job_data['arguments'].join("\n,")
  end

  def args_short
    h.short_text(args, max_length: 50)
  end

  def last_error_short
    h.short_text(model.last_error, max_length: 50)
  end
end
