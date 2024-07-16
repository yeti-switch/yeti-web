# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.api_log_config
#
#  id         :integer(4)       not null, primary key
#  controller :string           not null
#
# Indexes
#
#  api_log_config_controller_key  (controller) UNIQUE
#

FactoryBot.define do
  factory :api_log_config, class: 'System::ApiLogConfig' do
    sequence(:controller) { |n| "Api::Rest::Private::RateplansController_#{n}" }
  end
end
