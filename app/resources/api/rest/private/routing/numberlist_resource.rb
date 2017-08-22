class Api::Rest::Private::Routing::NumberlistResource < ::BaseResource
  immutable
  model_name 'Routing::Numberlist'
  type 'routing/numberlists'

  attributes :name, :created_at, :updated_at, :default_src_rewrite_rule, :default_src_rewrite_result,
             :default_dst_rewrite_rule, :default_dst_rewrite_result
end