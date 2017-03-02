Yeti::Application.config.app_build_info =  YAML.load_file(File.join(Rails.root, 'version.yml')) rescue {}
