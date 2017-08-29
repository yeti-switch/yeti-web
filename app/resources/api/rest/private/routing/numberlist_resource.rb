class Api::Rest::Private::Routing::NumberlistResource < ::BaseResource
  model_name 'Routing::Numberlist'

  attributes :name, :created_at, :updated_at, :default_src_rewrite_rule, :default_src_rewrite_result,
             :default_dst_rewrite_rule, :default_dst_rewrite_result
end