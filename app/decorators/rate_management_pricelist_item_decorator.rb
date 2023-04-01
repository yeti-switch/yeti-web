# frozen_string_literal: true

class RateManagementPricelistItemDecorator < ApplicationDecorator
  decorates RateManagement::PricelistItem

  def routing_tags
    h.routing_tags_badges(
      routing_tag_ids: model.routing_tag_ids,
      routing_tag_mode_id: model.routing_tag_mode_id
    )
  end

  def link_to_dialpeer
    # All applied pricelist items have empty dialpeer_id,
    # but dialpeer.id still present in detected_dialpeer_ids for types CHANGE and DELETE.
    return model.detected_dialpeer_ids.first || status_tag(:empty) if model.pricelist.applied?

    if model.type == RateManagement::PricelistItem::CONST::TYPE_ERROR
      h.link_to("Dialpeers (#{detected_dialpeer_ids.size})", dialpeers_path(q: { id_in_string: detected_dialpeer_ids.join(',') }))
    elsif dialpeer_id.nil?
      status_tag(:empty)
    else
      h.auto_link(model.dialpeer)
    end
  end

  def link_to_vendor
    vendor_id.nil? ? status_tag(:empty) : h.auto_link(model.vendor)
  end

  def link_to_account
    account_id.nil? ? status_tag(:empty) : h.auto_link(model.account)
  end

  def link_to_routing_group
    routing_group_id.nil? ? status_tag(:empty) : h.auto_link(model.routing_group)
  end

  def link_to_routeset_discriminator
    routeset_discriminator_id.nil? ? status_tag(:empty) : h.auto_link(model.routeset_discriminator)
  end

  def type_badge
    html = status_tag(model.type, class: type_color)
    html += status_tag('next rate', class: :no) if will_create_next_rate?
    html += status_tag('no change', class: :no) if nothing_changed?
    html.html_safe
  end

  def initial_rate
    changes_for_column(:initial_rate)
  end

  def next_rate
    changes_for_column(:next_rate)
  end

  def connect_fee
    changes_for_column(:connect_fee)
  end

  def initial_interval
    changes_for_column(:initial_interval)
  end

  def next_interval
    changes_for_column(:next_interval)
  end

  def dst_number_min_length
    changes_for_column(:dst_number_min_length)
  end

  def dst_number_max_length
    changes_for_column(:dst_number_max_length)
  end

  def enabled
    changes_for_column(:enabled)
  end

  def gateway
    changes_for_association(:gateway)
  end

  def gateway_group
    changes_for_association(:gateway_group)
  end

  def exclusive_route
    changes_for_column(:exclusive_route)
  end

  def acd_limit
    changes_for_column(:acd_limit)
  end

  def asr_limit
    changes_for_column(:asr_limit)
  end

  def capacity
    changes_for_column(:capacity)
  end

  def force_hit_rate
    changes_for_column(:force_hit_rate)
  end

  def lcr_rate_multiplier
    changes_for_column(:lcr_rate_multiplier)
  end

  def priority
    changes_for_column(:priority)
  end

  def reverse_billing
    changes_for_column(:reverse_billing)
  end

  def short_calls_limit
    changes_for_column(:short_calls_limit)
  end

  def src_name_rewrite_result
    changes_for_column(:src_name_rewrite_result)
  end

  def src_name_rewrite_rule
    changes_for_column(:src_name_rewrite_rule)
  end

  def src_rewrite_result
    changes_for_column(:src_rewrite_result)
  end

  def src_rewrite_rule
    changes_for_column(:src_rewrite_rule)
  end

  def dst_rewrite_result
    changes_for_column(:dst_rewrite_result)
  end

  def dst_rewrite_rule
    changes_for_column(:dst_rewrite_rule)
  end

  def valid_till
    if model.pricelist.dialpeers_detected? && model.type == RateManagement::PricelistItem::CONST::TYPE_DELETE
      new_valid_from = pricelist.valid_from.nil? ? 'NOW' : display_value(pricelist.valid_from)
      h.tag.b { "#{display_value(model.dialpeer.valid_till)} => #{new_valid_from}".html_safe }
    else
      changes_for_column(:valid_till)
    end
  end

  def valid_from
    # dialpeer_id is empty for applied pricelist, so we can't compare item and dialpeer columns.
    # Also item.valid_from always present after Apply changes.
    return display_value(model.valid_from) unless model.pricelist.dialpeers_detected?

    if model.type == RateManagement::PricelistItem::CONST::TYPE_CHANGE
      valid_from_type_change
    else
      # for items with empty valid_from and create type "valid from" always will be now at moment when we start apply
      model.valid_from.nil? ? 'NOW' : display_value(model.valid_from)
    end
  end

  def routing_tag_names
    return RateManagement::VerifyPricelistItems::NOT_TAGGED if model.routing_tag_ids.empty?

    names = model.routing_tags.map(&:name)
    names << Routing::RoutingTag::ANY_TAG if model.routing_tag_ids.include?(nil)
    names.join(', ')
  end

  private

  def type_color
    case model.type
    when RateManagement::PricelistItem::CONST::TYPE_CREATE
      :yes
    when RateManagement::PricelistItem::CONST::TYPE_CHANGE
      :notice
    when RateManagement::PricelistItem::CONST::TYPE_DELETE
      :warn
    when RateManagement::PricelistItem::CONST::TYPE_ERROR
      :error
    end
  end

  def changes_for_column(column)
    item_value = model.public_send(column)
    # dialpeer_id is empty for applied pricelist, so we can't compare item and dialpeer columns.
    return display_value(item_value) if model.pricelist.applied?
    return display_value(item_value) unless model.type == RateManagement::PricelistItem::CONST::TYPE_CHANGE

    dialpeer_value = model.dialpeer.public_send(column)
    return status_tag(:empty) if value_blank?(dialpeer_value) && value_blank?(item_value)
    return display_value(item_value) if dialpeer_value == item_value

    formatted_item_value = display_value(item_value)
    formatted_dialpeer_value = display_value(dialpeer_value)
    h.tag.b { "#{formatted_dialpeer_value} => #{formatted_item_value}".html_safe }
  end

  def changes_for_association(column)
    item_value = model.public_send(column)
    # dialpeer_id is empty for applied pricelist, so we can't compare item and dialpeer columns.
    return link_to_association(item_value) if model.pricelist.applied?
    return link_to_association(item_value) unless model.type == RateManagement::PricelistItem::CONST::TYPE_CHANGE

    item_key_value = model.public_send("#{column}_id")
    dialpeer_key_value = model.dialpeer.send("#{column}_id")
    return link_to_association(item_value) if dialpeer_key_value == item_key_value

    link_to_item_association = link_to_association(item_value)
    link_to_dialpeer_association = link_to_association(model.dialpeer.public_send(column))
    h.tag.b { "#{link_to_dialpeer_association} => #{link_to_item_association}".html_safe }
  end

  def display_value(value)
    return status_tag(:empty) if value_blank?(value)
    return status_tag(:yes) if value == true
    return status_tag(:no) if value == false
    return value.to_fs(:db) if value.is_a?(Time)

    value
  end

  def link_to_association(association)
    return status_tag(:empty) if association.nil?

    h.auto_link(association)
  end

  def value_blank?(value)
    return false if value == false

    value.blank?
  end

  def will_create_next_rate?
    return false unless model.pricelist.dialpeers_detected?
    return false if model.type != RateManagement::PricelistItem::CONST::TYPE_CHANGE

    !not_next_rate_fields_changed? && next_rate_fields_changed?
  end

  def nothing_changed?
    return false unless model.pricelist.dialpeers_detected?
    return false if model.type != RateManagement::PricelistItem::CONST::TYPE_CHANGE

    !not_next_rate_fields_changed? && !next_rate_fields_changed?
  end

  def next_rate_fields_changed?
    RateManagement::ApplyPricelist::NEXT_RATE_FIELDS.any? do |field|
      model.public_send(field) != model.dialpeer.public_send(field)
    end
  end

  def not_next_rate_fields_changed?
    RateManagement::ApplyPricelist::NON_NEXT_RATE_FIELDS.any? do |field|
      model.public_send(field) != model.dialpeer.public_send(field)
    end
  end

  def valid_from_type_change
    data_changed = !nothing_changed? # in sake of readability

    if data_changed && model.valid_from.nil?
      h.tag.b { "#{display_value(dialpeer.valid_from)} => NOW".html_safe }
    elsif data_changed && model.valid_from.present?
      changes_for_column(:valid_from)
    elsif nothing_changed? && model.valid_from.nil? && model.dialpeer.valid_from.past?
      display_value(model.dialpeer.valid_from)
    elsif nothing_changed? && model.valid_from.nil? && !model.dialpeer.valid_from.past?
      changes_for_column(:valid_from)
    elsif nothing_changed? && model.valid_from.present? && model.dialpeer.valid_from <= model.valid_from
      display_value(model.dialpeer.valid_from)
    else
      changes_for_column(:valid_from)
    end
  end
end
