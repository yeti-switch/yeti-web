# frozen_string_literal: true

class BatchUpdateForm::GatewayGroup < BatchUpdateForm::Base
  model_class 'GatewayGroup'
  attribute :vendor_id, type: :foreign_key, class_name: 'Contractor', scope: :vendors

  validates :vendor_id, presence: true, if: :vendor_id_changed?
end
