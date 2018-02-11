class TagActionValueValidator < ActiveModel::Validator
  def validate(record)

    tag_action_id = record.tag_action_id
    tag_action_value = record.tag_action_value.dup

    is_clear = tag_action_id.nil? || tag_action_id == Routing::TagAction::CONST::CLEAR_ID

    if !is_clear && tag_action_value.empty?
      record.errors.add(
        :tag_action_value,
        I18n.t('activerecord.errors.models.customer_auth.attributes.tag_action_value.empty_when_not_clear')
      )
    end

    if tag_action_value.present?
      if tag_action_value.include?(nil)
        record.errors.add(
          :tag_action_value,
          I18n.t('activerecord.errors.models.customer_auth.attributes.tag_action_value.empty_element')
        )
      end

      if tag_action_value.dup.uniq!.present?
        record.errors.add(
          :tag_action_value,
          I18n.t('activerecord.errors.models.customer_auth.attributes.tag_action_value.duplicate')
        )
      end
    end
  end
end
