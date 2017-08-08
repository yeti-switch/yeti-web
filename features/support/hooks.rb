require 'fileutils'

After('@change_color') do
  FileUtils.cd("#{Rails.root}/app/assets/stylesheets/themes")
  if File.exist?("old_variables.css.scss")
    File.delete("variables.css.scss")
    File.rename("old_variables.css.scss", "variables.css.scss")
  end
end

After('@change_logo_src') do
  FileUtils.cd("#{Rails.root}/config")
  if File.exist?("old_active_admin.yml")
    File.delete("active_admin.yml")
    File.rename("old_active_admin.yml", "active_admin.yml")
  else
    File.delete("active_admin.yml")
  end
end