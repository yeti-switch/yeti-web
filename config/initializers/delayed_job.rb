# frozen_string_literal: true

class Delayed::ActiveJobPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.before(:invoke_job) do |job|
      if job.payload_object.respond_to?(:job_data)
        job.payload_object.job_data['provider_job_id'] = job.id
      end
    end
  end
end

Delayed::Worker.plugins << Delayed::ActiveJobPlugin
Delayed::Worker.destroy_failed_jobs = false
