# frozen_string_literal: true

class SystemSchedulerDecorator < ApplicationDecorator
  decorates System::Scheduler

  def current_state_badge
    if current_state.nil?
      status_tag('Unknown', class: 'grey')
    elsif current_state
      status_tag('Blocking', class: 'red')
    else
      status_tag('Allowing', class: 'blue')
    end
  end
end
