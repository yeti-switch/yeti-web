# frozen_string_literal: true

class BatchUpdateForm::AreaPrefix < BatchUpdateForm::Base
  model_class 'Routing::AreaPrefix'
  attribute :area_id, type: :foreign_key, class_name: 'Routing::Area'
end
