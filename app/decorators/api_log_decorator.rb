# frozen_string_literal: true

class ApiLogDecorator < Draper::Decorator
  decorates Log::ApiLog
  delegate_all

  def status
    Arbre::Context.new(status: model.status.to_s, html_class: status_tag_class) do
      status_tag(assigns[:status], class: assigns[:html_class])
    end.to_s
  end

  delegate :method, to: :model

  def request_body
    if model.request_body.present?
      JSON.pretty_generate(JSON.parse(model.request_body))
    end
  end

  def response_body
    if model.response_body.present?
      JSON.pretty_generate(JSON.parse(model.response_body))
    end
  end

  def status_tag_class
    if (200..399) === model.status
      :ok
    elsif (400..499) === model.status
      :warning
    elsif (500..599) === model.status
      :error
    else
      ''
    end
  end
end
