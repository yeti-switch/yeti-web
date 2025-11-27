# frozen_string_literal: true

require 'activeadmin/tom_select/engine'
require 'activeadmin/tom_select/option_collection'
require 'activeadmin/tom_select/resource_extension'
require 'activeadmin/tom_select/resource_dsl_extension'
require 'activeadmin/tom_select/select_input_extension'
require 'activeadmin/tom_select/version'

ActiveAdmin::Resource.include ActiveAdmin::TomSelect::ResourceExtension
ActiveAdmin::ResourceDSL.include ActiveAdmin::TomSelect::ResourceDSLExtension

module ActiveAdmin
  # Global settings for searchable selects
  module TomSelect
    # Statically render all options into searchable selects with
    # `ajax` option set to true. This can be used to ease ui driven
    # integration testing.
    mattr_accessor :inline_ajax_options
    self.inline_ajax_options = false
  end
end
