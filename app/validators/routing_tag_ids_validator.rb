# frozen_string_literal: true

# NOTICE: can be rewritten as `ActiveModel::Validator`
# http://guides.rubyonrails.org/active_record_validations.html#custom-validators
class RoutingTagIdsValidator < ActiveModel::Validator
  def validate(record)
    if record.routing_tag_ids.dup.uniq!.present?
      record.errors.add(
        :routing_tag_ids,
        I18n.t('activerecord.errors.models.customers_auth.attributes.tag_action_value.duplicate')
      )
    end
  end
end
