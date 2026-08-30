# frozen_string_literal: true

require 'prometheus/yeti_info_processor'
require 'prometheus/semantic_logger_processor'

class Delayed::PrometheusPlugin < Delayed::Plugin
  def initialize
    # it called only when delayed job process started
    YetiInfoProcessor.start(labels: { app_type: 'delayed_job' })
    SemanticLoggerProcessor.start
    super
  end
end

Delayed::Worker.plugins << Delayed::PrometheusPlugin
