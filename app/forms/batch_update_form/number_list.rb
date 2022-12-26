# frozen_string_literal: true

class BatchUpdateForm::NumberList < BatchUpdateForm::Base
  model_class 'Routing::Numberlist'
  #attribute :mode_id, type: :foreign_key, class_name: 'Routing::NumberlistMode'
  #collection: Routing::Numberlist::MODES.invert
  #attribute :default_action_id, type: :foreign_key, class_name: 'Routing::NumberlistAction'
  #collection: Routing::Numberlist::DEFAULT_ACTIONS.invert

  attribute :default_src_rewrite_rule
  attribute :default_src_rewrite_result
  attribute :default_dst_rewrite_rule
  attribute :default_dst_rewrite_result
  attribute :lua_script_id, type: :foreign_key, class_name: 'System::LuaScript'
end
