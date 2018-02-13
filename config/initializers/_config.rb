Rails.configuration.yeti_web = begin
    YAML.load_file(File.join(Rails.root, '/config/yeti_web.yml')).freeze
rescue StandardError => e
   raise StandardError.new("Can't load /config/yeti_web.yml, message: #{e.message}")
end

