# frozen_string_literal: true

require 'jsonapi/exceptions/authorization_failed'
require 'jsonapi/exceptions/authentication_failed'
require 'jsonapi/operation_dispatcher_patch'
require 'jsonapi/relationship_patch'

JSONAPI.configure do |config|
  # can be paged, offset, none (default)
  config.default_paginator = :none
  config.default_page_size = 50
  config.maximum_page_size = 1_000
  config.top_level_meta_include_record_count = true
  config.top_level_meta_record_count_key = :total_count
end

module JsonapiResourceClassPatch
  # @example
  #   JSONAPI::Resource.register_resource_override 'api/rest/admin', 'Pop', 'Api::Rest::Admin::Pop'
  def register_resource_override(prefix, name, result)
    JSONAPI::Resource.resource_overrides.push(
      prefix: "#{prefix.underscore.chomp('/')}/",
      name: name.underscore.singularize,
      result: result.underscore
    )
  end

  def resource_overrides
    @resource_overrides ||= []

    # {
    #   'api/rest/admin/equipment/sip_schemas' => 'api/rest/admin/system/sip_schemas',
    #   'sip_schema' => 'api/rest/admin/system/sip_schemas',
    #   'api/rest/admin/equipment/pops' => 'api/rest/admin/pops',
    #   'pop' => 'api/rest/admin/pops',
    #   'api/rest/admin/equipment/nodes' => 'api/rest/admin/nodes',
    #   'node' => 'api/rest/admin/nodes'
    # }
  end

  def find_resource_override(type)
    type = type.underscore
    type = "#{module_path}#{type}" unless type.include?('/')
    singular_name = type.split('/').last.singularize
    found = JSONAPI::Resource.resource_overrides.detect do |opts|
      type.start_with?(opts[:prefix]) && singular_name == opts[:name]
    end
    found&.fetch(:result)
  end

  def resource_for(type)
    override = find_resource_override(type)
    unless override.nil?
      resource_name = _resource_name_from_type(override)
      return resource_name.constantize
    end

    super
  rescue StandardError => e
    Rails.logger.error { "Failed to detect #{name}.resource_for(#{type.inspect}) #{type.underscore}" }
    raise e
  end
end

JSONAPI::Resource.singleton_class.prepend(JsonapiResourceClassPatch)

JSONAPI::Resource.register_resource_override 'api/rest/admin', 'SipSchema', 'Api::Rest::Admin::System::SipSchema'
JSONAPI::Resource.register_resource_override 'api/rest/admin', 'Pop', 'Api::Rest::Admin::Pop'
JSONAPI::Resource.register_resource_override 'api/rest/admin', 'Node', 'Api::Rest::Admin::Node'
