# frozen_string_literal: true

class RateManagementProjectDecorator < ApplicationDecorator
  decorates RateManagement::Project

  def routing_tags
    h.routing_tags_badges(
      routing_tag_ids: model.routing_tag_ids,
      routing_tag_mode_id: model.routing_tag_mode_id
    )
  end

  def pricelists_link
    h.link_to 'Pricelists',
              h.rate_management_pricelists_path(q: { project_id_eq: model.id }),
              class: 'member_link'
  end

  def dialpeers_link
    h.link_to 'Dialpeers',
              h.dialpeers_path(q: dialpeers_scope),
              class: 'member_link'
  end

  private

  def dialpeers_scope
    {
      vendor_id_eq: model.vendor_id,
      account_id_eq: model.account_id,
      routing_group_id_eq: model.routing_group_id,
      routeset_discriminator_id_eq: model.routeset_discriminator_id
    }
  end
end
