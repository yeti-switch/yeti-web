require 'rails/generators'

class RolePolicyGenerator < Rails::Generators::Base
  argument :resource_class_name, type: :string
  argument :section_name, type: :string, optional: true

  def validate
    raise "resource_class_name #{resource_class_name.inspect} was not found" unless resource_class
  end

  def create_or_update_policy_file
    step = '  '
    if class_modules.any?
      modules_shift = step*class_modules.size
      modules_start = class_modules.map.with_index { |mod, idx| step*idx + "module #{mod}" }.join("\n")
      modules_start += "\n#{modules_shift}"
      modules_end = class_modules.map.with_index { |_, idx| step*idx + 'end' }.reverse.join("\n")
      modules_end += "\n#{modules_shift}"
    else
      modules_shift = ''
      modules_start = ''
      modules_end = ''
    end
    create_file file_path do
      <<-RUBY
#{modules_start}class #{class_name}Policy < ::RolePolicy
#{modules_shift + step}section '#{section}'

#{modules_shift + step}class Scope < ::RolePolicy::Scope
#{modules_shift + step}end

#{modules_shift}end
#{modules_end}
      RUBY
    end
  end

  def append_to_config_distr
    append_to_file config_file_distr_path do
      <<-YAML
  #{section}:
    read: true
    change: true
    remove: true
    perform: true
      YAML
    end
  end

  private

  def config_file_distr_path
    'config/policy_roles.yml.distr'
  end

  def file_path
    "app/policies/#{resource_path}_policy.rb"
  end

  def resource_class
    resource_class_name.safe_constantize
  end

  def resource_path
    resource_class_name.underscore
  end

  def class_name
    resource_class_name.split('::').last
  end

  def class_modules
    resource_class_name.split('::')[0...-1]
  end

  def section
    section_name.presence || resource_class_name.gsub('::', '/')
  end

end
