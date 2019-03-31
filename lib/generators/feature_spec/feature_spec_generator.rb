# frozen_string_literal: true

require 'rails/generators'
require_relative '../concerns/with_create_template'

class FeatureSpecGenerator < Rails::Generators::Base
  include WithCreateTemplate

  ALLOWED_ONLY = [
    :create
  ].freeze

  desc 'This generator create feature spec files to test active_admin resource (currently only new form)'

  source_root File.expand_path('templates', __dir__)
  argument :full_resource_name, type: :string, desc: 'section_name/resource_name'
  class_option :only, type: :string, default: 'create', desc: "only actions (#{ALLOWED_ONLY.join(',')}), all by default."

  def validate
    raise "FULL_RESOURCE_NAME #{full_resource_name.inspect} was not found" unless full_resource_name

    not_allowed_only = (generated_files - ALLOWED_ONLY)
    unless not_allowed_only.empty?
      raise "--only contains invalid values: #{not_allowed_only.join(',')}"
    end
  end

  def create_new_feature_spec_file
    return unless generated_files.include?(:create)

    destination = "spec/features/#{section_name}/#{resource_name_plural}/new_#{resource_name_singular}_spec.rb"
    create_from_template 'new_feature_spec.rb.erb', destination
  end

  private

  def resource_name
    full_resource_name.split('/').last
  end

  def section_name
    full_resource_name.split('/').first
  end

  def generated_files
    @options[:only].split(',').map(&:to_sym)
  end

  def resource_name_plural
    resource_name.pluralize
  end

  def resource_name_singular
    resource_name.singularize
  end

  def resource_name_singular_cap
    resource_name.singularize.humanize.split(' ').map(&:capitalize).join(' ')
  end
end
