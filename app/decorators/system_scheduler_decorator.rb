# frozen_string_literal: true

class SystemSchedulerDecorator < ApplicationDecorator
  decorates System::Scheduler

  def current_state_badge
    if current_state.nil?
      status_tag('Unknown', class: 'grey')
    elsif current_state
      status_tag('Traffic blocked', class: 'red')
    else
      status_tag('Traffic allowed', class: 'blue')
    end
  end

  def decorated_display_name
    h.safe_join([
                  h.auto_link(model, display_name),
                  current_state_badge
                ], ' ')
  end
end
