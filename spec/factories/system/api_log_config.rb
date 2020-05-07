# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.api_log_config
#
#  id         :integer          not null, primary key
#  controller :string           not null
#  debug      :boolean          default(FALSE), not null
#

FactoryGirl.define do
  factory :api_log_config, class: System::ApiLogConfig do
    sequence(:controller) { |n| "Api::Rest::Private::RateplansController_#{n}" }
  end
end
