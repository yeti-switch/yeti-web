# frozen_string_literal: true

require 'delayed/backend/base'

module Delayed
  # Name of a job: the class of the job and, for ActiveJob, the wrapped job class and
  # not the wrapper. Shared by the Background Tasks page(BackgroundTaskDecorator#name)
  # and by the `job` tag of the logs(Delayed::LogJobTagsPlugin), so that the name in the
  # logs is the same value the page shows.
  #
  # Delayed::Backend::Base#name is not used: for ActiveJob it returns display_name, that
  # also carries the job id and the queue.
  module JobName
    module_function

    # @param payload_object [Object] Delayed::Job#payload_object.
    # @return [String]
    def call(payload_object)
      return payload_object.job_data['job_class'] if payload_object.respond_to?(:job_data)

      payload_object.class.name
    end

    # For a job that does not deserialize any more, the only name left is the one written
    # in its YAML.
    #
    # @param handler [String] Delayed::Job#handler.
    # @return [String, nil] nil when the YAML holds no class name either.
    def from_handler(handler)
      Delayed::Backend::Base::ParseObjectFromYaml.match(handler.to_s)&.[](1)
    end
  end
end
