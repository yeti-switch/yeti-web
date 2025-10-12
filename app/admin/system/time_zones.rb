# frozen_string_literal: true

ActiveAdmin.register System::Timezone, as: 'time_zone' do
  menu false

  actions :none

  collection_action :search, method: :get do
    render json: [] and return if params.dig(:q, :search_for).blank?

    lowercase_search_query = params.dig(:q, :search_for).downcase
    data = Yeti::TimeZoneHelper.all { |entry| entry.downcase.include?(lowercase_search_query) }.map do |entry|
      { id: entry, value: entry }
    end
    render json: data
  end
end
