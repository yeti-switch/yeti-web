# frozen_string_literal: true

class RateManagementPricelistDecorator < ApplicationDecorator
  decorates RateManagement::Pricelist
  decorates_association :project, with: RateManagementProjectDecorator

  delegate :dialpeers_link, to: :project

  def link_to_items
    h.link_to "items (#{model.items_count})",
              rate_management_pricelist_pricelist_items_path(model),
              class: 'member_link'
  end

  def state_badge
    status_tag(state_name, class: state_color)
  end

  def background_job_badge
    if model.detect_dialpeers_in_progress? && model.new?
      status_tag('detect dialpeers', class: :warning)
    elsif model.detect_dialpeers_in_progress? && model.dialpeers_detected?
      status_tag('redetect dialpeers', class: :warning)
    elsif model.apply_changes_in_progress?
      status_tag('apply changes', class: :warning)
    else
      status_tag('nothing', class: :no)
    end
  end

  def has_background_job?
    model.detect_dialpeers_in_progress? || model.apply_changes_in_progress?
  end

  def valid_from
    model.valid_from || status_tag('now', class: :no)
  end

  private

  def state_color
    case model.state_id
    when RateManagement::Pricelist::CONST::STATE_ID_NEW
      :no
    when RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED
      :yes
    when RateManagement::Pricelist::CONST::STATE_ID_APPLIED
      :notice
    end
  end
end
