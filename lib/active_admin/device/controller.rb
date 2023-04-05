# frozen_string_literal: true

ActiveAdmin.before_load do
  module ActiveAdmin::Devise::Controller
    def root_path
      '/'
    end
  end
end
