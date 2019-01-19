# frozen_string_literal: true

require 'fileutils'

After('@change_color') do
  if File.exist?("#{Rails.root}/app/assets/stylesheets/hidden_themes")
    FileUtils.cd("#{Rails.root}/app/assets/stylesheets")
    FileUtils.rm_r("#{Rails.root}/app/assets/stylesheets/themes")
    File.rename("#{Rails.root}/app/assets/stylesheets/hidden_themes", "#{Rails.root}/app/assets/stylesheets/themes")
  end
end

After('@change_logo_src') do
  FileUtils.cd("#{Rails.root}/config")
  if File.exist?('old_yeti_web.yml')
    File.delete('yeti_web.yml')
    File.rename('old_yeti_web.yml', 'yeti_web.yml')
  else
    File.delete('yeti_web.yml')
  end
end
