require 'spec_helper'

RSpec.describe 'Change styles', js: true do
  let!(:admin_user) do
    FactoryGirl.create :admin_user, username: 'admin1',
      email: 'admin1@example.com',
      password: 'password'
  end

  context 'change_color' do
    before do
      # When I open variables.scss file and override variable "$text-color: blue !default;"
      File.rename("#{Rails.root}/app/assets/stylesheets/themes", "#{Rails.root}/app/assets/stylesheets/hidden_themes")
      FileUtils.mkdir("#{Rails.root}/app/assets/stylesheets/themes")
      FileUtils.cd("#{Rails.root}/app/assets/stylesheets/themes")
      new_file = File.new("#{Rails.root}/app/assets/stylesheets/themes/variables.scss", "w")
      new_file.puts "$text-color: blue !default;"
      new_file.close

      # sign in
      visit "/login"
      sleep 1
      within 'div#login' do
        find(:css, "input[type='text']").set('admin1')
        find(:css, "input[type='password']").set('password')
        find('[type="submit"]').click
      end

      # open dashboard
      visit "/dashboard"
      sleep 2
    end
    after do
      if File.exist?("#{Rails.root}/app/assets/stylesheets/hidden_themes")
        FileUtils.cd("#{Rails.root}/app/assets/stylesheets")
        FileUtils.rm_r("#{Rails.root}/app/assets/stylesheets/themes")
        File.rename("#{Rails.root}/app/assets/stylesheets/hidden_themes", "#{Rails.root}/app/assets/stylesheets/themes")
      end
    end

    it 'the page should be blue' do
      expect(page.evaluate_script("$('.footer p').css('color')")).to eq 'rgb(0, 0, 255)'
    end
  end

  context 'change logo src' do
    before do
      # create yeti_web yml
      FileUtils.cd("#{Rails.root}/config")
      if File.exist?("yeti_web.yml")
        File.rename("yeti_web.yml", "old_yeti_web.yml")
      end
      new_yml = File.new("yeti_web.yml", "w")
      new_yml.puts "site_title: 'Yeti Admin'"
      new_yml.close
      # add site image src
      FileUtils.cd("#{Rails.root}/config")
      File.open("yeti_web.yml", "a") do |file|
        file.puts "site_title_image: '/images/logo.png'"
      end
      # add role_policy
      FileUtils.cd("#{Rails.root}/config")
      File.open("yeti_web.yml", "a") do |file|
        file.puts 'role_policy:'
      end
      # add nested when_no_config: allow
      FileUtils.cd("#{Rails.root}/config")
      File.open("yeti_web.yml", "a") do |file|
        file.puts "  when_no_config: allow"
      end
      # add nested when_no_policy_class: raise
      FileUtils.cd("#{Rails.root}/config")
      File.open("yeti_web.yml", "a") do |file|
        file.puts "  when_no_policy_class: raise"
      end
      # reinit YetiWeb
      load "#{Rails.root}/config/initializers/_config.rb"
      load "#{Rails.root}/config/initializers/active_admin.rb"
      # sign in as admin_user
      visit "/login"
      sleep 1
      within 'div#login' do
        find(:css, "input[type='text']").set('admin1')
        find(:css, "input[type='password']").set('password')
        find('[type="submit"]').click
      end
      # open dashboard
      visit "/dashboard"
      sleep 2
    end
    after do
      FileUtils.cd("#{Rails.root}/config")
      if File.exist?("old_yeti_web.yml")
        File.delete("yeti_web.yml")
        File.rename("old_yeti_web.yml", "yeti_web.yml")
      else
        File.delete("yeti_web.yml")
      end

      it 'the title image src should be valid' do
        expect(page.evaluate_script("$('img#site_title_image').attr('src')")).to eq '/images/logo.png'
      end
    end
  end
end
