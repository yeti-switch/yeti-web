require 'fileutils'


And (/^I open the dashboard page$/) do
  visit "/dashboard"
  sleep 2
end

# change color scenario

When (/^I open variables.css.scss file and override variable "(.*?)"$/) do |variable|
  File.rename("#{Rails.root}/app/assets/stylesheets/themes", "#{Rails.root}/app/assets/stylesheets/hidden_themes")
  FileUtils.mkdir("#{Rails.root}/app/assets/stylesheets/themes")
  FileUtils.cd("#{Rails.root}/app/assets/stylesheets/themes")
  new_file = File.new("#{Rails.root}/app/assets/stylesheets/themes/variables.css.scss", "w")
  new_file.puts variable
  new_file.close
end

Then (/^The page text should be blue$/) do
  expect(page.evaluate_script("$('.footer p').css('color')")).to eq 'rgb(0, 0, 255)'
end

# change logo src scenario

When (/^I create yeti_web yml file and add site title "(.*?)"$/) do |title|
  FileUtils.cd("#{Rails.root}/config")
  if File.exist?("yeti_web.yml")
    File.rename("yeti_web.yml", "old_yeti_web.yml")
  end
  new_yml = File.new("yeti_web.yml", "w")
  new_yml.puts title
  new_yml.close
end

And (/^I add site image src "(.*?)"$/) do |image_src|
  FileUtils.cd("#{Rails.root}/config")
  File.open("yeti_web.yml", "a") do |file|
    file << image_src
    file.close
  end
end

And ("Reinitialize YetiWeb") do
  load "#{Rails.root}/config/initializers/_config.rb"
  load "#{Rails.root}/config/initializers/active_admin.rb"
end

Then (/^The title image src should be "(.*?)"$/) do |src|
  expect(page.evaluate_script("$('img#site_title_image').attr('src')")).to eq src
end
