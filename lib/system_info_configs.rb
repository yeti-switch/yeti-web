# frozen_string_literal: true

module SystemInfoConfigs
  module_function

  mattr_accessor :configs

  def loaded?
    configs.present?
  end

  def load_file(path)
    configs_attrs = YAML.load_file(path)
    configs_list = configs_attrs.map do |name, attrs|
      config = CustomStruct.new(attrs).tap(&:freeze)
      [name, config]
    end
    self.configs = configs_list.to_h
  end
end
