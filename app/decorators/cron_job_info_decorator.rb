# frozen_string_literal: true

class CronJobInfoDecorator < ApplicationDecorator
  def cron_line_formatted
    return "every #{model.every_interval}" if model.cron_line.nil?

    cron_description = Cronex::ExpressionDescriptor.new(model.cron_line).description
    h.with_tooltip(cron_description) { model.cron_line }
  end
end
