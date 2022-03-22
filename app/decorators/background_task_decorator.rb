# frozen_string_literal: true

class BackgroundTaskDecorator < Draper::Decorator
  delegate_all
  decorates BackgroundTask

  def name
    model.payload_object.job_data['job_class']
  end

  def args
    model.payload_object.job_data['arguments'].join("\n,")
  end

  def args_short
    h.short_text(args, max_length: 50)
  end

  def last_error_short
    h.short_text(model.last_error, max_length: 50)
  end
end
